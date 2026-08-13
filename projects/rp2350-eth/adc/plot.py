#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file plot.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from client import *

x = range(shift1 >> 3, 511, 2)
for i in x:
    print('{:3d} {:02x}{:02x} {:4d}'.format(i, data[i], data[i + 1],
                                            (data[i] << 8) + data[i + 1]))

import numpy as np
from matplotlib import pyplot

fig, ax = pyplot.subplots(figsize=(16, 9))
# big-endian unsigned short
y = np.frombuffer(data, dtype=np.dtype('>H'), count=255, offset=shift1 >> 3)
ax.plot(x, y, '-o')
pyplot.grid(axis="x")
pyplot.show()
