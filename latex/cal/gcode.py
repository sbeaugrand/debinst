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
sregular = 100  # Puissance du laser 15W en pourmille (vitesse de rotation)
fregular = 500  # Vitesse de deplacement en mm/min
sbold = 300
fbold = 300

with open("build/config.tex") as f:
    for line in f:
        if line.find('setlength{\sousStylaire') >= 0:
            sousStylaire = float(line.split('{')[2].split('c')[0]) * scale
        if line.find('setlength{\width') >= 0:
            width = float(line.split('{')[2].split('c')[0]) * scale
        if line.find('setlength{\horizon') >= 0:
            horizon = float(line.split('{')[2].split('c')[0]) * scale

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
## \fn xy2gcode
# ---------------------------------------------------------------------------- #
def xy2gcode(code, x, y):
    print('{} X{:.2f} Y{:.2f}'.format(code, x + offsetX, y + offsetY))


# ---------------------------------------------------------------------------- #
## \fn uv2gcode
# ---------------------------------------------------------------------------- #
def uv2gcode(code, x, y):
    print('{} X{:.2f} Y{:.2f}'.format(code, x, y))


# ---------------------------------------------------------------------------- #
## \fn dat2gcode
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
                    uv2gcode('G0', x, y)
                    print('M3')
                    first = False
                else:
                    uv2gcode('G1', x, y)
            else:
                print('M5')
                first = True


# ---------------------------------------------------------------------------- #
## \fn analemme
# ---------------------------------------------------------------------------- #
def analemme(hour):
    global first
    first = True
    if hour.find('_') >= 0:
        print('S{}'.format(sregular))
        print('G0 F{}'.format(fregular))
    dat2gcode('build/ete{}.dat'.format(hour))
    dat2gcode('build/aut{}.dat'.format(hour))
    dat2gcode('build/hiv{}.dat'.format(hour))
    dat2gcode('build/pri{}.dat'.format(hour))
    print('M5')
    if hour.find('_') >= 0:
        print('S{}'.format(sbold))
        print('G0 F{}'.format(fbold))


# ---------------------------------------------------------------------------- #
## \fn decorations
# ---------------------------------------------------------------------------- #
def decorations(hour):
    with open('build/{}{}.dat'.format(saison, hour)) as f:
        x1, y1 = [float(x) * scale for x in f.readline().split()]
        x2, y2 = [float(x) * scale for x in f.readline().split()]
        x1 += offsetX
        y1 += offsetY
        x2 += offsetX
        y2 += offsetY
        if x1 >= marginX and x1 < width - marginX and \
           y1 >= marginY and y1 < height - marginY:
            print('G0 X{:.2f} Y{:.2f}'.format(x1 + 0.5, y1))
            print('M3')
            print('G3 X{:.2f} Y{:.2f} I-0.5'.format(x1 + 0.5, y1))
            print('M5')
            if hour.find('_') < 0:
                if saison == 'hiv':
                    uv2gcode('G0', x1 - font.width, y1 + font.width)
                    font.draw('{}'.format(int(hour) + 1))
                if saison == 'ete':
                    uv2gcode('G0', x1 - font.width, y1 - font.width * 3)
                    font.draw('{}'.format(int(hour) + 2))


# ---------------------------------------------------------------------------- #
## \fn loop
# ---------------------------------------------------------------------------- #
def loop(a, b, f):
    if a < b:
        for i in range(a, b):
            f('{:02d}'.format(i))
            f('{:02d}_5'.format(i))
        f('{:02d}'.format(b))
    else:
        f('{:02d}'.format(a))
        for i in range(a - 1, b - 1, -1):
            f('{:02d}_5'.format(i))
            f('{:02d}'.format(i))


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
offsetX = width / 2
offsetY = height - sousStylaire - marginY
if not horizon < 1:
    offsetY -= horizon

print('G21')  # Programmation en mm
print('S{}'.format(sbold))
print('G0 F{}'.format(fbold))

first = True
loop(hmin, hmax, analemme)

print('(horizon)')
xy2gcode('G0', width / 2 - marginX, horizon)
print('M3')
xy2gcode('G1', 0, horizon)
print('M5')

print('(sous-stylaire)')
if horizon < 1:
    xy2gcode('G0', 0, 0)
    print('M3')
    xy2gcode('G1', 0, sousStylaire)
else:
    xy2gcode('G0', 0, -2)
    print('M3')
    xy2gcode('G1', 0, 2)
    print('M5')
    xy2gcode('G0', -2, 0)
    print('M3')
    xy2gcode('G1', 2, 0)
print('M5')

print('(horizon)')
xy2gcode('G0', 0, horizon)
print('M3')
xy2gcode('G1', -width / 2 + marginX, horizon)
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
