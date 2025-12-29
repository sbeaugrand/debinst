#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file papercone.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note pip install tikz-python
##       sudo apt-get install latexmk
# ---------------------------------------------------------------------------- #
from tikzpy import TikzPicture
import math

n = 16
r = 1.9
R = r / math.sin(math.radians(30))
e = 0.4

tikz = TikzPicture()
p = 2 * math.pi * r
h = math.sqrt(R * R - r * r)
A = math.degrees(4 * math.atan2(p / 4, h))
B = A / n
tikz.arc((R + e, 0), radius=R + e, start_angle=0, end_angle=A)
tikz.arc((R - e, 0), radius=R - e, start_angle=0, end_angle=A)
c1 = tikz.circle((0, 0), radius=R - 0.127, action='path')
c2 = tikz.circle((0, 0), radius=R + 0.127, action='path')
for a in [x * B for x in range(0, n + 1)]:
    tikz.circle(c1.point_at_arg(a), 0.03)
    tikz.circle(c2.point_at_arg(a), 0.03)
circle = tikz.circle((0, 0), radius=R, action='path')
c3 = tikz.circle(circle.point_at_arg(B / 2), radius=e * 2, options='dotted')
tikz.line(c3.point_at_arg(B / 2), c3.point_at_arg(B / 2 + 180))
tikz.line(c3.point_at_arg(B / 2 + 90), c3.point_at_arg(B / 2 + 270))
c4 = tikz.circle(circle.point_at_arg(A + B / 2), radius=0.4, action='path')
tikz.line(c4.point_at_arg(A + B / 2), c4.point_at_arg(A + B / 2 + 180))
tikz.line(c4.point_at_arg(A + B / 2 + 90), c4.point_at_arg(A + B / 2 + 270))
tikz.show()
