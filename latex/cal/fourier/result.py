#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file result.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from math import cos, sin
from pytz import timezone
from datetime import datetime

import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-f',
                    '--file',
                    default=sys.stdin,
                    type=argparse.FileType('r'))
args = parser.parse_args()
a0, a1, b1, a2, b2, a3, b3 = [float(x) for x in args.file.readline().split()]

#d = datetime.now().timetuple()[7]
n = datetime.now()
d = (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)[n.month - 1]
d += n.day
if n.year % 4 == 0:
    d += 1
w = 2 * 3.14159 / 365.25
m = a0
m += a1 * cos(1 * w * d) + b1 * sin(1 * w * d)
m += a2 * cos(2 * w * d) + b2 * sin(2 * w * d)
m += a3 * cos(3 * w * d) + b3 * sin(3 * w * d)
h = int(m // 60)
m = int(m - h * 60)
o = timezone('Europe/Paris').utcoffset(datetime.now()).total_seconds()
print(f'{h+int(o//3600):02d}:{m:02d}')
