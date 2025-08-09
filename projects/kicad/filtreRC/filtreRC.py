#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file filtreRC.py
## \author Sebastien Beaugrand
# ---------------------------------------------------------------------------- #
import sys
import argparse
import matplotlib.pyplot as pyplot

parser = argparse.ArgumentParser()
parser.add_argument('-d',
                    '--data',
                    default=sys.stdin,
                    type=argparse.FileType('r'))
args = parser.parse_args()

x1 = []
y1 = []
x2 = []
y2 = []
for line in args.data:
    tab = line.split()
    x1.append(float(tab[0]))
    y1.append(float(tab[1]))
    x2.append(float(tab[2]))
    y2.append(float(tab[3]))

pyplot.plot(x1, y1, '-', color='blue')
pyplot.plot(x2, y2, '-', color='red')
pyplot.show()
