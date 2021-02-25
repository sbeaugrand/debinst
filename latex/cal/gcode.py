#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gcode.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from gcode7seg import *

scale = 10
hmin = 7
hmax = 17
sregular = 100  # Puissance du laser en pourmille (vitesse de rotation)
fregular = 500  # Vitesse de déplacement en mm/min
sbold = 300
fbold = 300
G0 = 'G0'

with open("build/config.tex") as f:
    for line in f:
        if line.find('sousStylaire') >= 0:
            sousStylaire = float(line.split('{')[1].split('}')[0]) * scale
        if line.find('setlength{\width') >= 0:
            width = float(line.split('{')[2].split('c')[0]) * scale

if width < 300:
    width = 300
    height = 200
    marginY = 10
    font = gcode7seg(width=2, sep=1)
else:
    width = 600
    height = 300
    marginY = 5
    font = gcode7seg(width=4, sep=2)
marginX = 5

# ---------------------------------------------------------------------------- #
# \fn xy2gcode
# ---------------------------------------------------------------------------- #
def xy2gcode(code, x, y):
    print('{0} X{1:.2f} Y{2:.2f}'.format(code, x + offsetX, y + offsetY))

# ---------------------------------------------------------------------------- #
# \fn uv2gcode
# ---------------------------------------------------------------------------- #
def uv2gcode(code, x, y):
    print('{0} X{1:.2f} Y{2:.2f}'.format(code, x, y))

# ---------------------------------------------------------------------------- #
# \fn dat2gcode
# ---------------------------------------------------------------------------- #
def dat2gcode(file):
    global first
    with open(file) as f:
        for line in f:
            x, y = [float(x) * scale for x in line.split()]
            x += offsetX
            y += offsetY
            if x >= marginX and x < width - marginX and \
               y >= marginY and y < height - marginY:
                if first:
                    uv2gcode(G0, x, y)
                    print('M3')
                    first = False
                else:
                    uv2gcode('G1', x, y)

# ---------------------------------------------------------------------------- #
# \fn analemme
# ---------------------------------------------------------------------------- #
def analemme(hour):
    global first
    first = True
    if hour.find('_') >= 0:
        print('S{0}'.format(sregular))
        print('G0 F{0}'.format(fregular))
    dat2gcode('build/ete{0}.dat'.format(hour))
    dat2gcode('build/aut{0}.dat'.format(hour))
    dat2gcode('build/hiv{0}.dat'.format(hour))
    dat2gcode('build/pri{0}.dat'.format(hour))
    print('M5')
    if hour.find('_') >= 0:
        print('S{0}'.format(sbold))
        print('G0 F{0}'.format(fbold))

# ---------------------------------------------------------------------------- #
# \fn decorations
# ---------------------------------------------------------------------------- #
def decorations(hour):
    with open('build/{0}{1}.dat'.format(saison, hour)) as f:
        x1, y1 = [float(x) * scale for x in f.readline().split()]
        x2, y2 = [float(x) * scale for x in f.readline().split()]
        x1 += offsetX
        y1 += offsetY
        x2 += offsetX
        y2 += offsetY
        if x1 >= marginX and x1 < width - marginX and \
           y1 >= marginY and y1 < height - marginY:
            print('{0} X{1:.2f} Y{2:.2f}'.format(G0, x1 + 0.5, y1))
            print('M3')
            print('G3 X{0:.2f} Y{1:.2f} I-0.5'.format(x1 + 0.5, y1))
            print('M5')
            if hour.find('_') < 0:
                if saison == 'hiv':
                    uv2gcode(G0, x1 - font.width, y1 + font.width)
                    font.draw('{0}'.format(int(hour) + 1))
                if saison == 'ete':
                    uv2gcode(G0, x1 - font.width, y1 - font.width * 3);
                    font.draw('{0}'.format(int(hour) + 2))

# ---------------------------------------------------------------------------- #
# \fn loop
# ---------------------------------------------------------------------------- #
def loop(a, b, f):
    if a < b:
        for i in range(a, b):
            f('{0:02d}'.format(i))
            f('{0:02d}_5'.format(i))
        f('{0:02d}'.format(b))
    else:
        f('{0:02d}'.format(b))
        for i in range(a - 1, b - 1, -1):
            f('{0:02d}_5'.format(i))
            f('{0:02d}'.format(i))

# ---------------------------------------------------------------------------- #
# \fn main
# ---------------------------------------------------------------------------- #
offsetX = width / 2
offsetY = height - sousStylaire - marginY

print('G21')  # Programmation en mm
print('S{0}'.format(sbold))
print('G0 F{0}'.format(fbold))

first = True
loop(hmin, hmax, analemme)

xy2gcode(G0, width / 2 - marginX, 0)
print('M3')
xy2gcode('G1', 0, 0)
xy2gcode('G1', 0, sousStylaire)
print('M5')

xy2gcode(G0, 0, 0)
print('M3')
xy2gcode('G1', -width / 2 + marginX, 0)
print('M5')

saison = 'hiv'
loop(hmin, hmax, decorations)
saison = 'aut'
loop(hmax, hmin, decorations)
saison = 'pri'
loop(hmin, hmax, decorations)
saison = 'ete'
loop(hmax, hmin, decorations)

print('G0 X0 Y0')
print('M2')
