#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file faces2edges.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import argparse
from os import path

parser = argparse.ArgumentParser()
parser.add_argument('-f',
                    '--file',
                    default=sys.stdin,
                    type=argparse.FileType('r'))
args = parser.parse_args()


# ---------------------------------------------------------------------------- #
## \fn points
# ---------------------------------------------------------------------------- #
def points(line):
    pos = line.find('points="') + len('points="')
    end = line.find('"', pos)
    return line[pos:end].split()


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
prec = None
for line in args.file:
    if 'shape-rendering' not in line:
        print(line.replace('fill="#000000"','fill="white"'), end='')
        continue
    if prec is None:
        prec = line
        continue
    t1 = points(prec)
    t2 = points(line)
    if t1[1] == t2[2] and t1[2] == t2[1]:
        print('<polygon fill="white" stroke="black" stroke-width="2"'
              ' points="{} {} {} {}"/>'.format(t1[0], t1[1], t2[0], t2[1]))
    elif t1[0] == t2[1] and t1[1] == t2[0]:
        print('<polygon fill="white" stroke="black" stroke-width="2"'
              ' points="{} {} {} {}"/>'.format(t1[1], t1[2], t2[1], t2[2]))
    prec = None
