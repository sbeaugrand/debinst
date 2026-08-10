#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file rc-switch.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import spidev
from code2data import *

spi = spidev.SpiDev()
spi.open(2, 0)
spi.mode = 0
spi.max_speed_hz = 382253  # echo | awk '{ print 1e6*(24+24+8)/(150-7/2) }'
# (S1 = 24, S2 = 24, S3 = 8, 150 us per bit, adjusted by -0.5 us per SPI word)

for i in range(3):
    spi.writebytes(buff)
