#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gcode.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import argparse
from gcodefonts import *

parser = argparse.ArgumentParser()
parser.add_argument('-f',
                    '--font',
                    default='7seg',
                    choices=['7seg', 'oeralinda'],
                    help='default: 7seg')
parser.add_argument('-t',
                    '--tool',
                    type=int,
                    default=3,
                    choices=[1, 2, 3],
                    help='default: 3 (1 & 2)')
args = parser.parse_args()

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
    font = GcodeFonts.create(args.font, width=2, sep=1)
else:
    width = 600
    height = 300
    marginY = 5
    font = GcodeFonts.create(args.font, width=4, sep=2)
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
            elif not first:
                print('M5')
                first = True


# ---------------------------------------------------------------------------- #
## \fn analemme
# ---------------------------------------------------------------------------- #
def analemme(hour):
    global first
    first = True
    if args.tool == 3 and hour.find('_') >= 0:
        print('S{}'.format(sregular))
        print('F{}'.format(fregular))
    dat2gcode('build/ete{}.dat'.format(hour))
    dat2gcode('build/aut{}.dat'.format(hour))
    dat2gcode('build/hiv{}.dat'.format(hour))
    dat2gcode('build/pri{}.dat'.format(hour))
    if not first:
        print('M5')
        first = True
    if args.tool == 3 and hour.find('_') >= 0:
        print('S{}'.format(sbold))
        print('F{}'.format(fbold))


# ---------------------------------------------------------------------------- #
## \fn decorations
# ---------------------------------------------------------------------------- #
def decorations(hour):
    with open('build/{}{}.dat'.format(saison, hour)) as f:
        try:
            x, y = [float(x) * scale for x in f.readline().split()]
        except:
            return
        x += offsetX
        y += offsetY
        if x >= marginX and x < width - marginX and \
           y >= marginY and y < height - marginY:
            print('G0 X{:.2f} Y{:.2f}'.format(x + 0.5, y))
            print('M3')
            print('G3 X{:.2f} Y{:.2f} I-0.5'.format(x + 0.5, y))
            print('M5')
            if hour.find('_') < 0:
                if saison == 'hiv':
                    font.draw('{}'.format(int(hour) + 1), x - font.width,
                              y + font.width)
                if saison == 'ete':
                    font.draw('{}'.format(int(hour) + 2), x - font.width,
                              y - font.height - font.width)


# ---------------------------------------------------------------------------- #
## \fn loop
# ---------------------------------------------------------------------------- #
def loop(a, b, f):
    if a < b:
        for i in range(a, b):
            if args.tool & 1:
                f('{:02d}'.format(i))
            if args.tool & 2:
                f('{:02d}_5'.format(i))
        if args.tool & 1:
            f('{:02d}'.format(b))
    else:
        if args.tool & 1:
            f('{:02d}'.format(a))
        for i in range(a - 1, b - 1, -1):
            if args.tool & 2:
                f('{:02d}_5'.format(i))
            if args.tool & 1:
                f('{:02d}'.format(i))


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
offsetX = width / 2
offsetY = height - sousStylaire - marginY
if not horizon < 1:
    offsetY -= horizon

print('G21')  # Programmation en mm
if args.tool & 1:
    print('S{}'.format(sbold))
    print('F{}'.format(fbold))
else:
    print('S{}'.format(sregular))
    print('F{}'.format(fregular))

first = True
loop(hmin, hmax, analemme)

if args.tool & 1:
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
