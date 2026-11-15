#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file runecarver.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Usage: python3 runecarver.py build/rune.stl [-o build/rune.ngc]
#        sudo apt install python3-opencamlib python3-shapely python3-matplotlib
#
#        Usinage d'une rune en relief au fond d'une poche, avec une fraise
#        cylindrique, en deux passages :
#          1) a mi-hauteur de la poche (au-dessus des ilots) ;
#          2) au fond de la poche, autour des ilots (rune, oblong...).
#        Chaque passage est une poche en contours paralleles, calculee avec
#        les waterlines d'opencamlib : la trajectoire a la distance R des
#        parois est la waterline d'une fraise virtuelle de rayon R. On usine
#        de l'interieur (grand R) vers les bords (R = rayon de la fraise), en
#        avalant (broche M3 : poche parcourue dans le sens trigo, ilots dans
#        le sens horaire).
#        Les hauteurs sont deduites des faces horizontales du STL : dessus de
#        la piece, fond de la poche, haut des ilots.
#        Origine : celle du STL (centre de la piece, Z=0 sur le dessus).
# ---------------------------------------------------------------------------- #
import argparse
import math
import os
import sys
from functools import reduce

import opencamlib as ocl
from shapely.geometry import LineString, Point, Polygon
from shapely.geometry.polygon import orient
from shapely.ops import unary_union

LENGTH = 10.0     # Longueur utile de la fraise
SAMPLING = 0.1    # Echantillonnage des waterlines
MIN_SAMPLING = 0.01
SIMPLIFY = 0.005  # Tolerance de simplification des contours
AMIN = 0.01       # Aire en dessous de laquelle un contour est degenere
Z_APPROACH = 0.5  # Approche rapide au-dessus de la matiere
CLEARANCE = 0.04  # Garde au-dessus des ilots pour le premier passage


# ---------------------------------------------------------------------------- #
## \fn options
# ---------------------------------------------------------------------------- #
def options():
    p = argparse.ArgumentParser(
        description='Usinage d\'une rune en relief au fond d\'une poche')
    p.add_argument('stl', help='fichier STL (origine au centre du dessus)')
    p.add_argument('-o', '--output', help='G-code (defaut : .ngc du STL)')
    p.add_argument('--png', help='apercu des trajectoires '
                   '(defaut : .png du STL, "" pour aucun)')
    p.add_argument('-d', '--diameter', type=float, default=2.0,
                   help='diametre de la fraise (defaut : %(default)s)')
    p.add_argument('-s', '--step', type=float, default=0.8,
                   help='pas lateral entre contours (defaut : %(default)s)')
    p.add_argument('--z1', type=float,
                   help='Z du premier passage (defaut : mi-hauteur de la '
                   'poche, au-dessus des ilots)')
    p.add_argument('--z2', type=float,
                   help='Z du deuxieme passage (defaut : fond de la poche)')
    p.add_argument('--zsafe', type=float, default=5.0,
                   help='hauteur de degagement (defaut : %(default)s)')
    p.add_argument('-f', '--feed', type=int, default=300,
                   help='avance en mm/min (defaut : %(default)s)')
    p.add_argument('--plunge', type=int, default=100,
                   help='avance de plongee en mm/min (defaut : %(default)s)')
    p.add_argument('--ramp', type=float, default=0.15,
                   help='pente maximale des rampes (defaut : %(default)s)')
    p.add_argument('--spindle', type=int, default=12000,
                   help='vitesse de broche en tr/min (defaut : %(default)s)')
    a = p.parse_args()
    base = os.path.splitext(a.stl)[0]
    if a.output is None:
        a.output = base + '.ngc'
    if a.png is None:
        a.png = base + '.png'
    if a.step > a.diameter / 2:
        p.error('le pas doit etre inferieur au rayon de la fraise')
    return a


def log(*args):
    print(*args, file=sys.stderr)


# ---------------------------------------------------------------------------- #
## \fn heights
# ---------------------------------------------------------------------------- #
def heights(surf):
    """Hauteurs des faces horizontales tournees vers le haut : dessus de la
    piece, fond de la poche et haut des ilots."""
    zs = set()
    for t in surf.getTriangles():
        a, b, c = t.getPoints()
        if abs(a.z - b.z) > 1e-6 or abs(a.z - c.z) > 1e-6:
            continue
        nz = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        if nz > 0:
            zs.add(round(a.z, 4))
    zs = sorted(zs)
    if len(zs) < 2:
        sys.exit('pas de poche trouvee dans le STL')
    top = zs[-1]
    floor = zs[0]
    islands = zs[1:-1]
    return top, floor, (max(islands) if islands else None), \
        (min(islands) if islands else None)


def passes(surf, a):
    """Liste de (z d'usinage, z de calcul de la waterline, haut matiere)."""
    top, floor, itop, ilow = heights(surf)
    log('Dessus %.3f, fond %.3f, haut des ilots %s' %
        (top, floor, 'aucun' if itop is None else '%.3f' % itop))
    z2 = floor if a.z2 is None else a.z2
    z1 = a.z1
    if z1 is None:
        z1 = (top + z2) / 2
        if itop is not None and z1 <= itop + CLEARANCE:
            z1 = itop + CLEARANCE
    # Les ilots peuvent ne pas toucher le fond (ex. +m dans le .scad) :
    # la waterline du fond est calculee un peu au-dessus, les parois etant
    # verticales.
    zwl2 = z2 + 0.1
    if ilow is not None:
        zwl2 = min(zwl2, (z2 + ilow) / 2)
    if z1 <= z2 + 1e-6:
        return [(z2, zwl2, top)]
    return [(z1, z1, top), (z2, zwl2, z1)]


# ---------------------------------------------------------------------------- #
## \fn waterline
# ---------------------------------------------------------------------------- #
def waterline(surf, radius, z):
    """Contours du centre d'une fraise de rayon radius a la hauteur z,
    a l'interieur de la piece uniquement."""
    w = ocl.AdaptiveWaterline()
    w.setSTL(surf)
    w.setCutter(ocl.CylCutter(2 * radius, LENGTH))
    w.setZ(z)
    w.setSampling(SAMPLING)
    w.setMinSampling(MIN_SAMPLING)
    w.run()
    bb = surf.bb
    rings = []
    for loop in w.getLoops():
        pts = [(p.x, p.y) for p in loop]
        if len(pts) < 2:
            continue
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        # Le contour qui fait le tour exterieur du bloc est ignore
        if min(xs) <= bb.minpt.x or max(xs) >= bb.maxpt.x or \
           min(ys) <= bb.minpt.y or max(ys) >= bb.maxpt.y:
            continue
        rings.append(pts)
    return rings


# ---------------------------------------------------------------------------- #
## \class Region
# ---------------------------------------------------------------------------- #
class Region:
    """Composante connexe de la zone accessible au centre d'une fraise de
    rayon R : un contour exterieur (sens trigo) et des ilots (sens horaire)."""
    def __init__(self, poly, rings):
        self.poly = poly
        self.rings = rings
        self.children = []


def regions(rings):
    polys = []
    result = []
    for pts in rings:
        poly = Polygon(pts) if len(pts) >= 3 else None
        if poly is not None and poly.is_valid and poly.area >= AMIN:
            polys.append(poly)
        else:
            # Zone degeneree (presque une ligne) : on la parcourt telle quelle
            line = LineString(pts + [pts[0]])
            result.append(Region(line.buffer(1e-3), [list(line.coords)]))
    if polys:
        free = reduce(lambda a, b: a.symmetric_difference(b), polys)
        for g in getattr(free, 'geoms', [free]):
            if g.geom_type != 'Polygon' or g.area < AMIN:
                continue
            g = orient(g.simplify(SIMPLIFY, preserve_topology=True), 1.0)
            ring_list = [list(g.exterior.coords)]
            ring_list += [list(i.coords) for i in g.interiors]
            result.append(Region(g, ring_list))
    return result


def build_tree(surf, zwl, r0, step):
    """Calcule les contours de r0 vers l'interieur et les range en arbre :
    les enfants d'une region sont les regions plus interieures qu'elle
    contient."""
    levels = []
    k = 0
    while True:
        radius = r0 + k * step
        regs = regions(waterline(surf, radius, zwl))
        if not regs:
            break
        log('  R = %.2f : %d region(s)' % (radius, len(regs)))
        levels.append(regs)
        k += 1
    for k in range(1, len(levels)):
        for child in levels[k]:
            pt = child.poly.representative_point()
            parents = [p for p in levels[k - 1]
                       if p.poly.buffer(0.01).contains(pt)]
            if parents:
                parents[0].children.append(child)
            else:
                levels[0].append(child)
    return levels[0] if levels else []


# ---------------------------------------------------------------------------- #
## \class Gcode
# ---------------------------------------------------------------------------- #
class Gcode:
    def __init__(self, zsafe):
        self.lines = []
        self.x = 0.0
        self.y = 0.0
        self.z = zsafe
        self.paths = []    # Pour le dessin : (passage, debut, fin, coupe)
        self.npass = 0

    def emit(self, s):
        self.lines.append(s)

    def move(self, cmd, x=None, y=None, z=None, f=None):
        x = self.x if x is None else x
        y = self.y if y is None else y
        z = self.z if z is None else z
        s = cmd
        if abs(x - self.x) > 1e-6:
            s += ' X%.4f' % x
        if abs(y - self.y) > 1e-6:
            s += ' Y%.4f' % y
        if abs(z - self.z) > 1e-6:
            s += ' Z%.4f' % z
        if s == cmd:
            return
        if f is not None:
            s += ' F%d' % f
        self.emit(s)
        self.paths.append((self.npass, (self.x, self.y, self.z), (x, y, z),
                           cmd == 'G1'))
        self.x, self.y, self.z = x, y, z


def ring_from(coords, pos):
    """Contour ferme qui commence au point le plus proche de pos."""
    line = LineString(coords)
    d = line.project(Point(pos))
    start = line.interpolate(d)
    acc = 0.0
    for i in range(len(coords) - 1):
        seg = math.dist(coords[i], coords[i + 1])
        if acc + seg >= d:
            body = coords[i + 1:-1] + coords[:i + 1]
            s = (start.x, start.y)
            return [s] + body + [s]
        acc += seg
    return coords


def length(path):
    return sum(math.dist(path[i], path[i + 1]) for i in range(len(path) - 1))


# ---------------------------------------------------------------------------- #
## \class Pocket
# ---------------------------------------------------------------------------- #
class Pocket:
    def __init__(self, g, a, roots, zc, ztop):
        self.g = g
        self.a = a
        self.r0 = a.diameter / 2
        self.zc = zc
        self.ztop = ztop
        self.swept = Polygon()  # Zone deja usinee a cette profondeur
        self.free = unary_union([r.poly for r in roots]).buffer(1e-3)
        self.roots = roots

    def run(self):
        self.visit_list(self.roots)
        return self.swept

    def visit_list(self, nodes):
        todo = list(nodes)
        while todo:
            p = Point(self.g.x, self.g.y)
            n = min(todo, key=lambda r: r.poly.distance(p))
            todo.remove(n)
            self.visit(n)

    def visit(self, node):
        # Interieur d'abord, puis le contour de ce niveau
        self.visit_list(node.children)
        todo = list(node.rings)
        while todo:
            p = Point(self.g.x, self.g.y)
            ring = min(todo, key=lambda c: LineString(c).distance(p))
            todo.remove(ring)
            self.cut(ring_from(ring, (self.g.x, self.g.y)))

    def cut(self, path):
        g = self.g
        a = self.a
        start = path[0]
        link = LineString([(g.x, g.y), start])
        direct = abs(g.z - self.zc) < 1e-6 and (
            link.length < 1e-6 or (
                self.free.contains(link) and
                link.difference(self.swept).length <= 1.5 * a.step))
        if not direct:
            g.move('G0', z=a.zsafe)
            g.move('G0', x=start[0], y=start[1])
            g.move('G0', z=self.ztop + Z_APPROACH)
            if self.swept.buffer(-0.05).contains(Point(start)):
                g.move('G1', z=self.zc, f=a.plunge)
            else:
                g.move('G1', z=self.ztop, f=a.plunge)
                self.ramp(path)
        else:
            g.move('G1', x=start[0], y=start[1], f=a.feed)
        first = True
        for x, y in path[1:]:
            g.move('G1', x=x, y=y, f=a.feed if first else None)
            first = False
        self.swept = self.swept.union(LineString(path).buffer(self.r0))

    def ramp(self, path):
        """Rampe d'entree en suivant le contour (helice si le contour est
        court), pour finir au point de depart a la profondeur d'usinage."""
        g = self.g
        perim = length(path)
        depth = self.ztop - self.zc
        if perim < 0.1:
            g.move('G1', z=self.zc, f=self.a.plunge)
            return
        turns = math.ceil(depth / (perim * self.a.ramp))
        total = turns * perim
        acc = 0.0
        g.emit('F%d' % self.a.plunge)
        for _ in range(turns):
            for i in range(1, len(path)):
                acc += math.dist(path[i - 1], path[i])
                z = self.ztop - depth * acc / total
                g.move('G1', x=path[i][0], y=path[i][1], z=z)


# ---------------------------------------------------------------------------- #
## \fn plot
# ---------------------------------------------------------------------------- #
def plot(g, swept, plist, bb, filename):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.collections import LineCollection
    n = len(plist)
    w = bb.maxpt.x - bb.minpt.x
    h = bb.maxpt.y - bb.minpt.y
    fig, axes = plt.subplots(1, n, figsize=(6 * n, 6 * h / w + 0.5),
                             squeeze=False)
    for i, ax in enumerate(axes[0]):
        for geom in getattr(swept[i], 'geoms', [swept[i]]):
            if geom.is_empty:
                continue
            ax.fill(*geom.exterior.xy, color='#cde', zorder=0)
            for hole in geom.interiors:
                ax.fill(*hole.xy, color='white', zorder=1)
        cut = [(p[:2], q[:2]) for k, p, q, c in g.paths if k == i and c]
        rap = [(p[:2], q[:2]) for k, p, q, c in g.paths if k == i and not c]
        ax.add_collection(LineCollection(cut, colors='C0', linewidths=0.6))
        ax.add_collection(LineCollection(rap, colors='C3', linewidths=0.6,
                                         linestyles='dashed'))
        ax.set_title('Passage %d : Z = %.2f' % (i + 1, plist[i][0]))
        ax.set_aspect('equal')
        ax.set_xlim(bb.minpt.x, bb.maxpt.x)
        ax.set_ylim(bb.minpt.y, bb.maxpt.y)
    fig.tight_layout()
    fig.savefig(filename, dpi=150)


# ---------------------------------------------------------------------------- #
## \fn main
# ---------------------------------------------------------------------------- #
def main():
    a = options()
    r0 = a.diameter / 2
    surf = ocl.STLSurf()
    ocl.STLReader(a.stl, surf)
    if surf.size() == 0:
        sys.exit('%s : STL vide ou illisible' % a.stl)
    plist = passes(surf, a)
    g = Gcode(a.zsafe)
    g.emit('(%s : fraise cylindrique D%.2f, origine du STL)' %
           (os.path.basename(a.stl), a.diameter))
    g.emit('G21 G90 G17 G94')
    g.emit('G0 Z%.4f' % a.zsafe)
    g.emit('M3 S%d' % a.spindle)
    g.emit('G4 P2')
    swept = []
    for i, (zc, zwl, ztop) in enumerate(plist):
        log('Passage %d : Z = %.3f' % (i + 1, zc))
        g.npass = i
        g.emit('(Passage %d : Z = %.3f)' % (i + 1, zc))
        roots = build_tree(surf, zwl, r0, a.step)
        if not roots:
            sys.exit('aucune trajectoire : la fraise ne passe nulle part')
        swept.append(Pocket(g, a, roots, zc, ztop).run())
        # Controle : la zone accessible a la fraise est-elle entierement
        # usinee ?
        target = unary_union([r.poly for r in roots]).buffer(r0)
        left = target.difference(swept[-1].buffer(1e-3)).area
        log('  zone accessible %.2f mm2, non usinee %.4f mm2' %
            (target.area, left))
    g.move('G0', z=a.zsafe)
    g.emit('M5')
    g.emit('M2')
    with open(a.output, 'w') as f:
        f.write('\n'.join(g.lines) + '\n')
    cut = sum(math.dist(p, q) for k, p, q, c in g.paths if c)
    log('%s : %d lignes, %.0f mm usines (~%.1f min)' %
        (a.output, len(g.lines), cut, cut / a.feed))
    if a.png:
        try:
            plot(g, swept, plist, surf.bb, a.png)
            log(a.png)
        except ImportError:
            pass


if __name__ == '__main__':
    main()
