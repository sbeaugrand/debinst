#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file rc-switch.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import spidev
import time
from code2data import *

spi = spidev.SpiDev()
spi.open(2, 0)
spi.mode = 0
spi.max_speed_hz = 400000

for i in range(6):
    spi.xfer2(buff)
    time.sleep(0.001)
