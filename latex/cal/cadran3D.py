#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file cadran3D.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \brief create a 3D sundial mold
## \todo replace the sphere by a polyhedron to minimize plastic
## \note numbers will be better placed later
## \test pip3 install pymeeus
##       pip3 install solidpython
##       ./cadran3D.py 48.44728 1.48749 100 50 ~/cadran3D.scad
##       openscad ~/cadran3D.scad &
# ---------------------------------------------------------------------------- #
import sys
import math as m
from datetime import datetime
from threading import Thread
from pymeeus.Angle import *
from pymeeus.Epoch import Epoch
from pymeeus.Coordinates import true_obliquity, nutation_longitude, equatorial2horizontal
from pymeeus.Sun import Sun
from solid import *


# ---------------------------------------------------------------------------- #
## \fn debugf
# ---------------------------------------------------------------------------- #
def debugf(dic):
    if not debug:
        return
    print('debug: ', end='', file=sys.stderr)
    print(', '.join('{} = {:.7f}'.format(k, v) for k, v in dic.items()),
          file=sys.stderr)


# ---------------------------------------------------------------------------- #
## \fn point
# ---------------------------------------------------------------------------- #
def point(year, month, day, hour):
    day += hour / 24
    epoch = Epoch(year, month, day)

    ra, dec, _ = Sun.apparent_rightascension_declination_coarse(epoch)
    debugf({'ra': ra._deg, 'dec': dec._deg})

    theta0 = epoch.apparent_sidereal_time(true_obliquity(year, month, day),
                                          nutation_longitude(year, month, day))
    theta0 *= 24 * 15
    azi, ele = equatorial2horizontal(
        Angle(Angle.reduce_deg(theta0 + lon - ra)), dec, Angle(lat))
    debugf({'theta0': theta0, 'azi': azi._deg, 'ele': ele._deg})

    if ele < 0:
        return (None, None, None)

    azi = m.radians(azi._deg)
    ele = m.radians(ele._deg)

    theta = m.atan(r * m.tan(azi) / R)
    if azi > -m.pi / 2 and azi < m.pi / 2:
        theta += m.pi

    delta = m.atan(R * m.tan(ele) * m.sin(azi) / m.sin(theta) / r)

    y = -R * m.cos(delta) * m.cos(theta)
    x = -R * m.cos(delta) * m.sin(theta)
    z = r * m.sin(delta)
    return (x, y, z)


# ---------------------------------------------------------------------------- #
## \class Analemme
# ---------------------------------------------------------------------------- #
class Analemme(Thread):
    DEPTH = 3
    WIDTH = 1

    def __init__(self, year, hour):
        Thread.__init__(self)
        self.year = year
        self.hour = hour

    def number(self, n):
        return linear_extrude(height=self.DEPTH)(text(str(n),
                                                      font='DejaVu Sans',
                                                      size=3))

    def run(self):
        self.objects = union()
        ymin = (0, R, 0)
        ymax = (0, -R, 0)
        for dnum in range(1, 366):
            date = datetime.strptime('{:04d}{:03d}'.format(self.year, dnum),
                                     '%Y%j')
            if date.month > 6:
                col = 'red'
            else:
                col = 'blue'
            x, y, z = point(self.year, date.month, date.day, self.hour)
            if x is None:
                continue
            if ymin[1] > y:
                ymin = (x, y, z)
            if ymax[1] < y:
                ymax = (x, y, z)
            self.objects += color(col)(translate([x, y, z - self.DEPTH])(cube(
                [self.WIDTH, self.WIDTH, self.DEPTH + MARGIN])))
        self.objects += translate([ymin[0], ymin[1] - 5, ymin[2] - self.DEPTH
                                   ])(self.number(self.hour + 2))
        if ymax[2] > -self.DEPTH:
            return
        self.objects += translate([ymax[0], ymax[1] + 5, ymax[2] - self.DEPTH
                                   ])(self.number(self.hour + 1))


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if len(sys.argv) != 6 and len(sys.argv) != 10:
    print('Usage: {} <lat> <lon> <R-sphere-mm> <r-sphere-mm> <filename>'
          ' [year] [month] [day] [hour]'.format(sys.argv[0]))
    exit(1)
lat = float(sys.argv[1])
lon = float(sys.argv[2])
R = float(sys.argv[3])
r = float(sys.argv[4])
filename = sys.argv[5]
if len(sys.argv) == 10:
    debug = True
    year = int(sys.argv[6])
    month = int(sys.argv[7])
    day = int(sys.argv[8])
    hour = float(sys.argv[9])
    point(year, month, day, hour)
    exit(0)
else:
    debug = False
MARGIN = 1

objects = union()
threads = list()
year = datetime.today().year
for hour in range(5, 20):
    t = Analemme(year, hour)
    t.start()
    threads.append(t)
for t in threads:
    t.join()
    objects += t.objects

styledroit = translate([0, 0, -r - MARGIN])(cylinder(h=r + MARGIN * 2,
                                                     r1=5,
                                                     r2=0,
                                                     segments=180))
demisphere = styledroit
demisphere += resize(newsize=[R * 2, R * 2, r * 2])(sphere(r=r, segments=180))
demisphere -= translate([-R, -R, 0])(cube([R * 2, R * 2, r + MARGIN]))
demisphere -= styledroit
objects += color('white', 0.2)(demisphere)

scad_render_to_file(objects, filename)
