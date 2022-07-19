#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file knotsvg.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import bezier
import numpy as np
import svgwrite
import sys
from math import *
scale = 10


# ---------------------------------------------------------------------------- #
## \class Svg
# ---------------------------------------------------------------------------- #
class Svg:
    def __init__(self):
        w = 20 * scale
        h = 12 * scale
        self.d = svgwrite.Drawing(sys.argv[1], (460, 460 * h / w))
        self.d.viewbox(0, -11 * scale, w, h)
        self.cp = self.d.clipPath()
        self.gr = self.d.g()


# ---------------------------------------------------------------------------- #
## \class Path
# ---------------------------------------------------------------------------- #
class Path:
    def __init__(self, strand_angle):
        self.strand_angle = strand_angle
        self.lx = None
        self.ly = None
        self.la = None
        self.le = None
        self.xlist = list()
        self.ylist = list()

    def __compute_curve(self, svg, nodes, depth):
        curve = bezier.Curve(nodes, degree=3)
        n = int(round(20 * curve.length / scale))
        s_vals = np.linspace(0.0, 1.0, n)
        points = curve.evaluate_multi(s_vals)
        allp = list()

        k = 0
        for i in range(0, n):
            t = curve.evaluate_hodograph(s_vals[i])
            cx = points[0][i]
            cy = points[1][i]
            ca = atan2(t[1][0], t[0][0]) + self.strand_angle
            ce = 0.25 * scale
            if self.lx is None:
                self.lx = cx
                self.ly = cy
                self.la = ca
                self.le = ce
                continue
            else:
                d1 = np.abs(cx - self.lx) + np.abs(cy - self.ly) + np.abs(
                    ce * np.tan(ca - self.la))
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
            p = svg.d.path(
                d=('M {0},{1} C {2},{3} {2},{3} {4},{5} L{6},{7} ' +
                   'M {6},{7} C {8},{9} {8},{9} {10},{11} L{0},{1}').format(
                       x2, y2, x2 + (x3 - x2) / 2 + (x2 - x1) / 5,
                       y2 + (y3 - y2) / 2 + (y2 - y1) / 5, x3, y3, x4, y4,
                       x4 + (x1 - x4) / 2 + (x1 - x2) / 5,
                       y4 + (y1 - y4) / 2 + (y1 - y2) / 5, x1, y1),
                stroke_width=0.02 * scale)
            svg.d.defs.add(p)
            if i > k and i < n - 1:
                if depth > 0:
                    svg.cp.add(svg.d.use(p, insert=(0, 0.1 * scale)))
                    svg.cp.add(svg.d.use(p, insert=(0, -0.05 * scale)))
                    svg.cp.add(svg.d.use(p, insert=(0.05 * scale, 0)))
                    svg.cp.add(svg.d.use(p, insert=(-0.05 * scale, 0)))
                else:
                    svg.gr.add(svg.d.use(p))
            allp.append(p.get_iri())
            self.lx = cx
            self.ly = cy
            self.la = ca
            self.le = ce
        return allp

    def compute_path(self, svg, allp, depth, xlist, ylist):
        k = 0
        for i in range(0, len(xlist) - 1, 3):
            nodes = np.asfortranarray([xlist[i:i + 4], ylist[i:i + 4]])
            allp.append(self.__compute_curve(svg, nodes, depth[k]))
            k += 1
        return k


# ---------------------------------------------------------------------------- #
## \class knotsvg
# ---------------------------------------------------------------------------- #
class knotsvg:
    def __init__(self,
                 paths,
                 depth,
                 xscale=1.0,
                 yscale=1.0,
                 title=False,
                 title_insert=(0, 0)):
        self.svg = Svg()
        self.strand_angle = pi / 5
        self.xscale = xscale * 10
        self.yscale = yscale * 10
        self.__trace(paths, depth)
        if title:
            if type(title) is list:
                for i in range(0, len(title)):
                    self.__trace_text(title[i], title_insert[i])
            else:
                self.__trace_text(title, title_insert)
        self.svg.d.save()

    def __trace_text(self, text, insert):
        self.svg.d.add(
            self.svg.d.text(text,
                            insert=(insert[0] * scale, insert[1] * scale),
                            style='font-size:5px; font-family:Arial'))

    def __compute_paths(self, paths, depth, allp):
        k = 0
        for path in paths:
            p = Path(self.strand_angle)
            rel = False
            relx = 0
            rely = 0
            i = 0
            for t in path.split():
                if t == 'M' or t == 'm':
                    if i > 0:
                        k += p.compute_path(self.svg, allp, depth[k:], p.xlist,
                                            p.ylist)
                        p = Path(self.strand_angle)
                        i = 0
                    if t == 'M':
                        rel = False
                        continue
                    if t == 'm':
                        rel = True
                        continue
                if t == 'C':
                    rel = False
                    continue
                if t == 'c':
                    rel = True
                    continue
                x = float(t.split(',')[0]) * self.xscale
                y = float(t.split(',')[1]) * self.yscale
                if rel:
                    x += relx
                    y += rely
                p.xlist.append(x)
                p.ylist.append(y)
                if i % 3 == 0:
                    relx = x
                    rely = y
                i += 1
            k += p.compute_path(self.svg, allp, depth[k:], p.xlist, p.ylist)
            self.strand_angle = -self.strand_angle

    def __trace_paths(self, allp, depth, upper):
        for j in range(0, len(allp)):
            if upper:
                if depth[j] < 0:
                    continue
            else:
                if depth[j] >= 0:
                    continue
            for p in allp[j]:
                self.svg.d.add(self.svg.d.use(p, fill='white', stroke='black'))

    def __trace(self, paths, depth):
        allp = list()
        self.__compute_paths(paths, depth, allp)
        self.__trace_paths(allp, depth, upper=False)
        self.svg.d.defs.add(self.svg.cp)
        self.svg.d.defs.add(self.svg.gr)
        self.svg.d.add(
            self.svg.d.use(self.svg.gr,
                           fill='black',
                           clip_path='url({})'.format(self.svg.cp.get_iri())))
        self.__trace_paths(allp, depth, upper=True)
