#!/usr/bin/env python
# ------------------------------------------------ #
## \file plot.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ------------------------------------------------ #
import sys
import numpy as np
import matplotlib.pyplot as plt

plt.ion()
x = range(32)
fig, ax = plt.subplots()

while True:
    buff = sys.stdin.buffer.read(320)
    if len(buff) != 320: exit(0)
    data = np.frombuffer(buff, dtype='uint8', count=32)

    ax.cla()
    ax.bar(x, height=data)
    fig.canvas.flush_events()

plt.ioff()
plt.show()
