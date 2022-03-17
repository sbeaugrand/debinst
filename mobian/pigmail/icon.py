#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file icon.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import svgwrite
from math import *
import sys

pink = '#F0C0C0'
darkpink = '#E0A0A0'
brown = '#804020'
darkbrown = '#703010'

w = 36
h = 25
d = svgwrite.Drawing(sys.argv[1], (800, 800 * h / w))
d.viewbox(0, -h, w, h)

# oreilles
R = 15
a = 5
r = 1
x = (R - r) * cos(radians(a))
y = (R - r) * sin(radians(a))
cx = x - y / tan(pi / 3)
cy = 0
mx = R
my = (R - cx) * tan(pi / 3)

a1 = d.path(d='M{},{} L{},{}'.format(x, y, x + r * cos(radians(a)),
                                     y + r * sin(radians(a))),
            fill=darkpink,
            stroke=darkpink,
            stroke_width=0.1)
a1.push_arc((x + r * cos(pi / 3), y + r * sin(pi / 3)),
            60 - a,
            r,
            large_arc=False,
            absolute=True)
a1.push('Z')

a2 = d.path(d='M{},{} L{},{}'.format(cx, cy, R, 0),
            fill=darkpink,
            stroke=darkpink,
            stroke_width=0.1)
a2.push_arc((R * cos(radians(a)), R * sin(radians(a))),
            a,
            R,
            large_arc=False,
            absolute=True)
a2.push('L{},{} Z'.format(x, y))

p = d.g(transform='translate({}, 0)'.format(-cx))
p.add(a1)
p.add(a2)

t = d.g(transform='scale(1.2, 0.8) rotate(-30)')
t.add(p)
t.add(d.use(p, insert=(0, 0), transform='rotate(120)'))
t.add(d.use(p, insert=(0, 0), transform='rotate(240)'))
t.add(d.use(p, insert=(0, 0), transform='scale(1, -1)'))
t.add(d.use(p, insert=(0, 0), transform='scale(1, -1) rotate(120)'))
t.add(d.use(p, insert=(0, 0), transform='scale(1, -1) rotate(240)'))
d.defs.add(t)

# oreille droite
d.add(d.use(t, insert=(0, 0), transform='translate(3, -20) rotate(-45)'))
# pieds
d.add(d.rect(insert=(6., -0.5 - 3), size=(4, 3), fill=darkbrown, rx=0.5))
d.add(d.rect(insert=(6., -2.2 - 5), size=(4, 5), fill=darkpink))
d.add(d.rect(insert=(16, -0.5 - 3), size=(4, 3), fill=darkbrown, rx=0.5))
d.add(d.rect(insert=(16, -2.2 - 5), size=(4, 5), fill=darkpink))
d.add(d.rect(insert=(13, -0.5 - 3), size=(4, 3), fill=brown, rx=0.5))
d.add(d.rect(insert=(13, -2.2 - 5), size=(4, 5), fill=pink))
d.add(d.rect(insert=(23, -0.5 - 3), size=(4, 3), fill=brown, rx=0.5))
d.add(d.rect(insert=(23, -2.2 - 5), size=(4, 5), fill=pink))
# queue
d.add(
    d.path(d='M 0,0 C 3,-6 11,-3 9,1 8,3 5,3 4,1 2,-3 10,-6 13,0',
           fill='none',
           stroke=darkpink,
           stroke_width=1.5,
           stroke_linecap='round',
           transform='translate(29,-20) scale(0.5,0.5) rotate(-30)'))
# corps
d.add(d.rect(insert=(1.5, -4 - 20), size=(30, 20), ry=10, fill=pink))
# yeux
d.add(d.rect(insert=(5., -16.5 - 2), size=(1, 2), rx=0.5, fill=brown))
d.add(d.rect(insert=(15, -16.5 - 2), size=(1, 2), rx=0.5, fill=brown))
# groin
d.add(d.rect(insert=(7, -12 - 5), size=(7, 5), ry=2.5, fill=darkpink))
# narines
d.add(d.rect(insert=(9., -13.75 - 1.5), size=(1, 1.5), rx=0.5, fill=brown))
d.add(d.rect(insert=(11, -13.75 - 1.5), size=(1, 1.5), rx=0.5, fill=brown))
# oreille gauche
d.add(d.use(t, insert=(0, 0), transform='translate(19, -20) rotate(45)'))
# enveloppe
x = 5.2
y = 4.5
w = 162 / 15
h = 114 / 15
d.add(
    d.rect(insert=(x, -y - h),
           size=(w, h),
           fill='white',
           stroke='black',
           stroke_width=0.1))
d.add(
    d.polyline(points=[(x, -y - h), (x + w / 2, -y - h + w / 2),
                       (x + w, -y - h)],
               fill='white',
               stroke='black',
               stroke_width=0.1))

d.save()
