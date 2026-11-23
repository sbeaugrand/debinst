#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file knotsvg.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \brief Dessin de noeuds ; la partie geometrique (Cubic, Strand, layers)
##        est commune avec l'extension Inkscape inkscape/knotsvg_inkscape.py
# ---------------------------------------------------------------------------- #
import re
import sys
from math import atan2, cos, sin, tan, pi

scale = 10
strand_angle = pi / 5
## Decalages (en unites knotsvg) des copies d'un brin du dessus qui
## decoupent l'ombre portee sur les brins du dessous
clip_offsets = ((0, 0.1), (0, -0.05), (0.05, 0), (-0.05, 0))


# ---------------------------------------------------------------------------- #
## \class Cubic
## \brief Courbe de Bezier cubique
# ---------------------------------------------------------------------------- #
class Cubic:
    def __init__(self, xs, ys):
        self.xs = xs
        self.ys = ys

    def evaluate(self, t):
        u = 1 - t
        c = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
        return (sum(c[i] * self.xs[i] for i in range(4)),
                sum(c[i] * self.ys[i] for i in range(4)))

    def hodograph(self, t):
        u = 1 - t
        c = (u * u, 2 * u * t, t * t)
        xs = self.xs
        ys = self.ys
        return (3 * sum(c[i] * (xs[i + 1] - xs[i]) for i in range(3)),
                3 * sum(c[i] * (ys[i + 1] - ys[i]) for i in range(3)))

    def length(self, steps=64):
        def speed(t):
            dx, dy = self.hodograph(t)
            return (dx * dx + dy * dy)**0.5

        h = 1.0 / steps
        s = speed(0.0) + speed(1.0)
        for i in range(1, steps):
            s += (4 if i % 2 else 2) * speed(i * h)
        return s * h / 3


def linspace(n):
    if n == 1:
        return [0.0]
    return [i / (n - 1) for i in range(n)]


# ---------------------------------------------------------------------------- #
## \class Strand
## \brief Un brin continu (sous-chemin) decoupe en tranches de toron
# ---------------------------------------------------------------------------- #
class Strand:
    def __init__(self, strand_angle):
        self.strand_angle = strand_angle
        self.lx = None
        self.ly = None
        self.la = None
        self.le = None

    ## \return liste de (d, inner) : inner indique si la tranche
    ##         participe a l'ombre
    def __compute_curve(self, curve):
        n = int(round(20 * curve.length() / scale))
        s_vals = linspace(n)
        slices = list()

        k = 0
        for i in range(0, n):
            tx, ty = curve.hodograph(s_vals[i])
            cx, cy = curve.evaluate(s_vals[i])
            ca = atan2(ty, tx) + self.strand_angle
            ce = 0.25 * scale
            if self.lx is None:
                self.lx = cx
                self.ly = cy
                self.la = ca
                self.le = ce
                continue
            else:
                d1 = abs(cx - self.lx) + abs(cy - self.ly) + abs(
                    ce * tan(ca - self.la))
                if (d1 < ce * 1.75):
                    k += 1
                    continue
            if i == n - 1:
                break
            x1 = self.lx + self.le * cos(self.la)
            y1 = self.ly + self.le * sin(self.la)
            x2 = self.lx - self.le * cos(self.la)
            y2 = self.ly - self.le * sin(self.la)
            x3 = cx - ce * cos(ca)
            y3 = cy - ce * sin(ca)
            x4 = cx + ce * cos(ca)
            y4 = cy + ce * sin(ca)
            d = ('M {0},{1} C {2},{3} {2},{3} {4},{5} L{6},{7} ' +
                 'M {6},{7} C {8},{9} {8},{9} {10},{11} L{0},{1}').format(
                     x2, y2, x2 + (x3 - x2) / 2 + (x2 - x1) / 5,
                     y2 + (y3 - y2) / 2 + (y2 - y1) / 5, x3, y3, x4, y4,
                     x4 + (x1 - x4) / 2 + (x1 - x2) / 5,
                     y4 + (y1 - y4) / 2 + (y1 - y2) / 5, x1, y1)
            slices.append((d, i > k and i < n - 1))
            self.lx = cx
            self.ly = cy
            self.la = ca
            self.le = ce
        return slices

    ## \return liste de (slices, milieu) par segment de Bezier
    def compute_path(self, xlist, ylist):
        curves = list()
        for i in range(0, len(xlist) - 1, 3):
            curve = Cubic(xlist[i:i + 4], ylist[i:i + 4])
            curves.append((self.__compute_curve(curve), curve.evaluate(0.5)))
        return curves


# ---------------------------------------------------------------------------- #
## \brief Repartit les tranches selon la profondeur de leur segment
## \return (lower, upper, shadow, clip) : listes de chemins d ; lower et
##         upper sont dessines en blanc cerne de noir, shadow en noir
##         decoupe par clip (a decaler de clip_offsets)
# ---------------------------------------------------------------------------- #
def layers(curves, depth):
    lower = list()
    upper = list()
    shadow = list()
    clip = list()
    for j, (slices, _) in enumerate(curves):
        for d, inner in slices:
            if inner:
                (clip if depth[j] > 0 else shadow).append(d)
            (upper if depth[j] >= 0 else lower).append(d)
    return lower, upper, shadow, clip


# ---------------------------------------------------------------------------- #
## \brief Extrait tous les nombres d'une chaine (accepte "[1, -1]", "(1,2)"...)
# ---------------------------------------------------------------------------- #
def parse_numbers(text):
    return [
        float(v)
        for v in re.findall(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?', text)
    ]


# ---------------------------------------------------------------------------- #
## \brief Decoupe un chemin 'M x,y C x,y ...' en sous-chemins
## \return liste de (xlist, ylist) en unites internes
# ---------------------------------------------------------------------------- #
def parse_path(path, xscale, yscale):
    subpaths = list()
    xlist = list()
    ylist = list()
    rel = False
    relx = 0
    rely = 0
    for t in path.split():
        if t in ('M', 'm', 'C', 'c'):
            if t in ('M', 'm') and xlist:
                subpaths.append((xlist, ylist))
                xlist = list()
                ylist = list()
            rel = t in ('m', 'c')
            continue
        x = float(t.split(',')[0]) * xscale
        y = float(t.split(',')[1]) * yscale
        if rel:
            x += relx
            y += rely
        if len(xlist) % 3 == 0:
            relx = x
            rely = y
        xlist.append(x)
        ylist.append(y)
    if xlist:
        subpaths.append((xlist, ylist))
    return subpaths


# ---------------------------------------------------------------------------- #
## \class knotsvg
## \brief Ecrit le noeud dans le fichier SVG sys.argv[1] ; chaque element de
##        paths, meme une chaine vide, inverse le sens des torons
# ---------------------------------------------------------------------------- #
class knotsvg:
    def __init__(self,
                 paths,
                 depth,
                 xscale=1.0,
                 yscale=1.0,
                 title=False,
                 title_insert=(0, 0)):
        import svgwrite
        w = 20 * scale
        h = 12 * scale
        self.d = svgwrite.Drawing(sys.argv[1], (460, 460 * h / w))
        self.d.viewbox(0, -11 * scale, w, h)
        curves = list()
        angle = strand_angle
        for path in paths:
            for xlist, ylist in parse_path(path, xscale * scale,
                                           yscale * scale):
                curves += Strand(angle).compute_path(xlist, ylist)
            angle = -angle
        self.__trace(*layers(curves, depth))
        if title:
            if type(title) is list:
                for i in range(0, len(title)):
                    self.__trace_text(title[i], title_insert[i])
            else:
                self.__trace_text(title, title_insert)
        self.d.save()

    def __trace_text(self, text, insert):
        self.d.add(
            self.d.text(text,
                        insert=(insert[0] * scale, insert[1] * scale),
                        style='font-size:5px; font-family:Arial'))

    ## \brief Chaque chemin est defini une fois dans defs puis reference
    def __ref(self, d):
        if d not in self.refs:
            p = self.d.path(d=d, stroke_width=0.02 * scale)
            self.d.defs.add(p)
            self.refs[d] = p
        return self.refs[d]

    def __trace_paths(self, paths):
        for d in paths:
            self.d.add(self.d.use(self.__ref(d), fill='white', stroke='black'))

    def __trace(self, lower, upper, shadow, clip):
        self.refs = dict()
        for d in lower + upper:
            self.__ref(d)
        cp = self.d.clipPath()
        for d in clip:
            for dx, dy in clip_offsets:
                cp.add(self.d.use(self.__ref(d), insert=(dx * scale, dy * scale)))
        gr = self.d.g()
        for d in shadow:
            gr.add(self.d.use(self.__ref(d)))
        self.__trace_paths(lower)
        self.d.defs.add(cp)
        self.d.defs.add(gr)
        self.d.add(
            self.d.use(gr,
                       fill='black',
                       clip_path='url({})'.format(cp.get_iri())))
        self.__trace_paths(upper)
