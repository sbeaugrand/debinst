#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file plot.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import matplotlib.pyplot as pyplot
import sys

x1 = []
y1 = []
x2 = []
y2 = []
with open(sys.argv[1], 'r') as file:
    for line in file:
        tab = line.split()
        x1.append(float(tab[0]))
        y1.append(float(tab[1]))
with open(sys.argv[2], 'r') as file:
    for line in file:
        tab = line.split()
        x2.append(float(tab[0]))
        y2.append(float(tab[1]))

pyplot.plot(x1, y1, '-', color='blue')
pyplot.plot(x2, y2, '-', color='red')
pyplot.show()
