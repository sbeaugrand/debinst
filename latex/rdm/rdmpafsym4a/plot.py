#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file plot.py
## \author Sebastien Beaugrand
# ---------------------------------------------------------------------------- #
import matplotlib.pyplot as pyplot
from solve import *

x = [L * i / 100 for i in range(0, 100)]
y = [f(L * i / 100) for i in range(0, 100)]

pyplot.plot(x, y, '-')
pyplot.show()
