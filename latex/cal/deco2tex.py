#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file deco2tex.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t',
                    '--tool',
                    type=int,
                    default=3,
                    choices=[1, 2, 3],
                    help='default: 3 (1 & 2)')
args = parser.parse_args()

scale = 1
hmin = 7
hmax = 17
width = 60
height = 30
marginX = 0.9
marginY = 0.9

with open("build/config.tex") as f:
    for line in f:
        if line.find('setlength{\sousStylaire') >= 0:
            sousStylaire = float(line.split('{')[2].split('c')[0]) * scale
        if line.find('setlength{\horizon') >= 0:
            horizon = float(line.split('{')[2].split('c')[0]) * scale


# ---------------------------------------------------------------------------- #
## \fn decorations
# ---------------------------------------------------------------------------- #
def decorations(hour):
    with open('build/{}{}.dat'.format(saison, hour)) as f:
        try:
            x, y = [float(x) * scale for x in f.readline().split()]
        except:
            return
        if x + offsetX >= marginX and x + offsetX < width - marginX and \
           y + offsetY >= marginY and y + offsetY < height - marginY:
            print(
                '\\draw[color=red,very thick] ({},{}) circle (0.5mm);'.format(
                    x, y))


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

saison = 'hiv'
loop(hmin, hmax, decorations)
saison = 'aut'
loop(hmax, hmin, decorations)
saison = 'pri'
loop(hmin, hmax, decorations)
saison = 'ete'
loop(hmax, hmin, decorations)
