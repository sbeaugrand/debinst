#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file sundial3D.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import argparse
import math as m
from abc import ABC, abstractmethod
from datetime import datetime
from threading import Thread
from pymeeus.Angle import *
from pymeeus.Epoch import Epoch
from pymeeus.Coordinates import true_obliquity, nutation_longitude, equatorial2horizontal
from pymeeus.Sun import Sun
from solid import *

MARGIN = 0.1
RSTYLE = 5

parser = argparse.ArgumentParser(
    epilog='''
example: pip3 install pymeeus
         pip3 install solidpython
         ./sundial3D.py -s sphere     --draft -o ~/sundial3Ds.scad
         ./sundial3D.py -s polyhedron --draft -o ~/sundial3Dp.scad
         ./sundial3D.py -s wall       --draft -o ~/sundial3Dw.scad
         openscad ~/sundial3Dw.scad &
''',
    formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('--lat',
                    type=float,
                    default=48.44728,
                    help='default: 48.44728 (deg)')
parser.add_argument('--lon',
                    type=float,
                    default=1.48749,
                    help='default: 1.48749 (deg)')
parser.add_argument('-s',
                    '--shape',
                    default='wall',
                    choices=['sphere', 'polyhedron', 'wall'],
                    help='default: wall')
parser.add_argument('-R',
                    '--R',
                    type=int,
                    default=100,
                    help='R sphere, default: 100 (mm)')
parser.add_argument('-r',
                    '--r',
                    type=int,
                    default=50,
                    help='r sphere, default: 50 (mm)')
parser.add_argument('--draft', action='store_true')
parser.add_argument('-o', '--output')
parser.add_argument('--debug', action='store_true')
parser.add_argument('-y', '--year', type=int, default=datetime.today().year)
parser.add_argument('-m', '--month', type=int)
parser.add_argument('-d', '--day', type=int)
parser.add_argument('-H', '--hour', type=int)
args = parser.parse_args()


# ---------------------------------------------------------------------------- #
## \fn debugf
# ---------------------------------------------------------------------------- #
def debugf(dic):
    if not args.debug:
        return
    print('debug: ', end='', file=sys.stderr)
    print(', '.join('{} = {:.7f}'.format(k, v) for k, v in dic.items()),
          file=sys.stderr)


# ---------------------------------------------------------------------------- #
## \fn azi_ele
# ---------------------------------------------------------------------------- #
def azi_ele(year, month, day, hour):
    day += hour / 24
    epoch = Epoch(year, month, day)

    ra, dec, _ = Sun.apparent_rightascension_declination_coarse(epoch)
    debugf({'ra': ra._deg, 'dec': dec._deg})

    theta0 = epoch.apparent_sidereal_time(true_obliquity(year, month, day),
                                          nutation_longitude(year, month, day))
    theta0 *= 24 * 15
    azi, ele = equatorial2horizontal(
        Angle(Angle.reduce_deg(theta0 + args.lon - ra)), dec, Angle(args.lat))
    debugf({'theta0': theta0, 'azi': azi._deg, 'ele': ele._deg})

    if ele < 0:
        return None

    azi = m.radians(azi._deg)
    ele = m.radians(ele._deg)
    return (azi, ele)


# ---------------------------------------------------------------------------- #
## \class Triangle
# ---------------------------------------------------------------------------- #
class Triangle:
    def __init__(self, a, b, c):
        self.a = a
        self.b = b
        self.c = c
        self.v0 = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
        self.v1 = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
        self.n1 = self.v0[1] * self.v1[2] - self.v0[2] * self.v1[1]
        self.n2 = self.v0[2] * self.v1[0] - self.v0[0] * self.v1[2]
        self.n3 = self.v0[0] * self.v1[1] - self.v0[1] * self.v1[0]
        n = (self.n1 * self.n1 + self.n2 * self.n2 + self.n3 * self.n3)**0.5
        self.n1 /= n
        self.n2 /= n
        self.n3 /= n
        self.d = -self.n1 * a[0] - self.n2 * a[1] - self.n3 * a[2]

    def contains(self, v2):
        v0 = self.v0
        v1 = self.v1
        # Dot products
        dot00 = v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2]
        dot01 = v0[0] * v1[0] + v0[1] * v1[1] + v0[2] * v1[2]
        dot02 = v0[0] * v2[0] + v0[1] * v2[1] + v0[2] * v2[2]
        dot11 = v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]
        dot12 = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2]
        # Barycentric coordinates
        invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
        u = (dot11 * dot02 - dot01 * dot12) * invDenom
        v = (dot00 * dot12 - dot01 * dot02) * invDenom

        return u >= 0 and v >= 0 and u + v < 1

    def intersect(self, u, v, w):
        t = -self.d / (self.n1 * u + self.n2 * v + self.n3 * w)
        x = u * t
        y = v * t
        z = w * t
        v2 = (x - self.a[0], y - self.a[1], z - self.a[2])
        if self.contains(v2):
            return (x, y, z, self.n1, self.n2, self.n3)
        else:
            return None


# ---------------------------------------------------------------------------- #
## \class Quadrilateral
# ---------------------------------------------------------------------------- #
class Quadrilateral:
    def __init__(self, a, b, c, d):
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.t = list()
        self.t.append(Triangle(a, b, c))
        self.t.append(Triangle(a, c, d))

    def contains(self, p):
        for t in self.t:
            v2 = (p[0] - t.a[0], p[1] - t.a[1], p[2] - t.a[2])
            if t.contains(v2):
                return (p[0], p[1], p[2], t.n1, t.n2, t.n3)
        return None

    def intersect(self, u, v, w):
        for t in self.t:
            p = t.intersect(u, v, w)
            if p is not None:
                return p
        return None

    def polyhedron(self):
        tr = self.t[0]
        points = [
            self.a, self.b, self.c, self.d,
            [self.a[0] - tr.n1, self.a[1] - tr.n2, self.a[2] - tr.n3],
            [self.b[0] - tr.n1, self.b[1] - tr.n2, self.b[2] - tr.n3],
            [self.c[0] - tr.n1, self.c[1] - tr.n2, self.c[2] - tr.n3],
            [self.d[0] - tr.n1, self.d[1] - tr.n2, self.d[2] - tr.n3]
        ]
        faces = [[0, 1, 2, 3], [4, 5, 1, 0], [7, 6, 5, 4], [5, 6, 2, 1],
                 [6, 7, 3, 2], [7, 4, 0, 3]]
        return polyhedron(points=points, faces=faces)


# ---------------------------------------------------------------------------- #
## \class Shape
# ---------------------------------------------------------------------------- #
class Shape(ABC):
    @abstractmethod
    def intersect(self, year, month, day, hour):
        pass

    def styledroit(self):
        return translate([0, 0,
                          -args.r - MARGIN])(cylinder(h=args.r + MARGIN * 2,
                                                      r1=RSTYLE,
                                                      r2=0,
                                                      segments=180))


# ---------------------------------------------------------------------------- #
## \class Sphere
# ---------------------------------------------------------------------------- #
class Sphere(Shape):
    def __init__(self):
        pass

    def intersect(self, year, month, day, hour):
        c = azi_ele(year, month, day, hour)
        if c is None:
            return None
        azi, ele = c

        theta = m.atan(args.r * m.tan(azi) / args.R)
        if azi > -m.pi / 2 and azi < m.pi / 2:
            theta += m.pi

        delta = m.atan(args.R * m.tan(ele) * m.sin(azi) / m.sin(theta) /
                       args.r)

        y = -args.R * m.cos(delta) * m.cos(theta)
        x = -args.R * m.cos(delta) * m.sin(theta)
        z = args.r * m.sin(delta)
        return (x, y, z, 0, 0, -1)

    def normal_vector(self, p):
        return (p[0], p[1], p[2], 0, 0, -1)

    def draw(self):
        s = self.styledroit()
        demisphere = s
        demisphere += resize(newsize=[args.R * 2, args.R * 2, args.r * 2])(
            sphere(r=args.r, segments=180))
        demisphere -= translate([-args.R, -args.R, 0])(cube(
            [args.R * 2, args.R * 2, args.r + MARGIN]))
        demisphere -= s
        return color('white', 0.2)(demisphere)


# ---------------------------------------------------------------------------- #
## \class Polyhedron
# ---------------------------------------------------------------------------- #
class Polyhedron(Shape):
    def __init__(self):
        self.quadrilaterals = list()
        self.quadrilaterals.append(
            Quadrilateral((-args.R, RSTYLE, -args.r), (-args.R, args.R, 0),
                          (args.R, args.R, 0), (args.R, RSTYLE, -args.r)))
        a = self.intersect(args.year, 6, 21, 8.5)
        b = self.intersect(args.year, 12, 21, 8.5)
        if a[0] is None or b[0] is None:
            print(a)
            print(b)
            exit(1)
        a = (a[0], RSTYLE, -args.r)
        b = (b[0], args.R, 0)
        c = (-b[0], b[1], b[2])
        d = (-a[0], a[1], a[2])
        e = (b[0], -b[1], b[2])
        f = (a[0], -a[1], a[2])
        self.quadrilaterals = list()
        self.quadrilaterals.append(Quadrilateral(a, b, c, d))
        self.quadrilaterals.append(Quadrilateral(f, e, b, a))
        if not args.draft:
            g = (-b[0], -b[1], b[2])
            h = (-a[0], -a[1], a[2])
            self.quadrilaterals.append(Quadrilateral(d, c, g, h))

    def normal_vector(self, point):
        for q in self.quadrilaterals:
            p = q.contains(point)
            if p is not None:
                return p
        return None

    def intersect(self, year, month, day, hour):
        c = azi_ele(year, month, day, hour)
        if c is None:
            return None
        azi, ele = c

        azi = m.pi * 3 / 2 - azi
        u = m.cos(ele) * m.cos(azi)
        v = m.cos(ele) * m.sin(azi)
        w = m.sin(ele)

        for q in self.quadrilaterals:
            p = q.intersect(u, v, w)
            if p is not None:
                return p
        return None

    def draw(self):
        o = color('white', 0.2)(self.styledroit())
        for q in self.quadrilaterals:
            o += color('white', 0.2)(q.polyhedron())
        return o


# ---------------------------------------------------------------------------- #
## \class Wall
# ---------------------------------------------------------------------------- #
class Wall(Polyhedron):
    def __init__(self):
        a = (-300, 65, -280)
        b = (-300, 65, 0)
        c = (300, 65, 0)
        d = (300, 65, -280)
        e = (-300, -180, 0)
        f = (-300, -180, -280)
        self.quadrilaterals = list()
        self.quadrilaterals.append(Quadrilateral(a, b, c, d))
        self.quadrilaterals.append(Quadrilateral(f, e, b, a))
        if not args.draft:
            g = (300, -180, 0)
            h = (300, -180, -280)
            self.quadrilaterals.append(Quadrilateral(d, c, g, h))


# ---------------------------------------------------------------------------- #
## \class Analemme
# ---------------------------------------------------------------------------- #
class Analemme(Thread):
    WIDTH = 0.5

    def __init__(self, shape, year, hour, minu=0):
        Thread.__init__(self)
        self.shape = shape
        self.year = year
        self.hour = hour + minu / 60
        self.minu = minu
        if minu == 0:
            self.depth = 2
        else:
            self.depth = 1
        self.objects = union()
        if type(self.shape) is Wall:
            self.min = (0, 0, 0)
            self.max = (0, 0, -args.r)
        else:
            self.min = (0, args.R, 0)
            self.max = (0, -args.R, 0)

    def number(self, n):
        return linear_extrude(height=self.depth)(text(str(n),
                                                      font='DejaVu Sans',
                                                      size=3))

    def draw_numbers(self):
        rx = 0
        ry = 0
        rz = 0
        p = self.shape.normal_vector(self.min)
        if p is not None:
            x, y, z, n1, n2, n3 = p
            if n3 == -1:
                pass
            elif n1 == 0:
                rx = 180 - m.degrees(m.atan2(n2, n3))
            elif n2 == 0:
                ry = 180 + m.degrees(m.atan2(n1, n3))
        self.objects += translate([self.min[0], self.min[1], self.min[2]])(
            rotate([rx, ry,
                    rz])(translate([0, -5, -self.depth
                                    ])(self.number(int(self.hour) + 2))))
        if self.max[2] > -self.depth:
            return
        rx = 0
        ry = 0
        rz = 0
        p = self.shape.normal_vector(self.min)
        if p is not None:
            x, y, z, n1, n2, n3 = p
            if n3 == -1:
                pass
            elif n1 == 0:
                rx = 180 - m.degrees(m.atan2(n2, n3))
            elif n2 == 0:
                ry = 180 + m.degrees(m.atan2(n1, n3))
        self.objects += translate([self.max[0], self.max[1], self.max[2]])(
            rotate([rx, ry,
                    rz])(translate([0, 5, -self.depth
                                    ])(self.number(int(self.hour) + 1))))

    def run(self):
        for dnum in range(1, 366):
            date = datetime.strptime('{:04d}{:03d}'.format(self.year, dnum),
                                     '%Y%j')
            if date.month > 6:
                col = 'red'
            else:
                col = 'blue'
            rx = 0
            ry = 0
            rz = 0
            p = self.shape.intersect(self.year, date.month, date.day,
                                     self.hour)
            if p is None:
                continue
            x, y, z, n1, n2, n3 = p
            if n3 == -1:
                pass
            elif n1 == 0:
                rx = -m.degrees(m.atan2(n2, n3))
            elif n2 == 0:
                ry = m.degrees(m.atan2(n1, n3))
            if type(self.shape) is Wall:
                if self.min[2] > z:
                    self.min = (x, y, z)
                if self.max[2] < z:
                    self.max = (x, y, z)
            else:
                if self.min[1] > y:
                    self.min = (x, y, z)
                if self.max[1] < y:
                    self.max = (x, y, z)
            self.objects += color(col)(translate([x, y, z])(rotate(
                [rx, ry,
                 rz])(cube([self.WIDTH, self.WIDTH, self.depth + MARGIN]))))
        if self.minu == 0:
            self.draw_numbers()


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if args.debug:
    azi_ele(args.year, args.month, args.day, args.hour)
    exit(0)

if args.shape == 'sphere':
    shape = Sphere()
elif args.shape == 'polyhedron':
    shape = Polyhedron()
elif args.shape == 'wall':
    shape = Wall()

objects = union()

threads = list()
for hour in range(5, 13 if args.draft else 20):
    t = Analemme(shape, args.year, hour)
    t.start()
    threads.append(t)
    if not args.draft and hour < 19:
        t = Analemme(shape, args.year, hour, minu=30)
        t.start()
        threads.append(t)
for t in threads:
    t.join()
    objects += t.objects

objects += shape.draw()
scad_render_to_file(objects, args.output)
