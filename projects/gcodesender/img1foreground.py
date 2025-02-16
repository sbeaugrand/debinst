#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file img1foreground.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from PIL import Image

if len(sys.argv) <= 2:
    print(f'Usage: {sys.argv[0]} <png> <foreground.png>', file=sys.stderr)
    exit(1)
srcName = sys.argv[1]
dstName = sys.argv[2]

# Remove background
src = Image.open(srcName)
dst = Image.new("RGB", src.size, "white")
dstPx = dst.load()
srcPx = src.load()
for j in range(0, src.height - 1):
    for i in range(0, src.width - 1):
        p = srcPx[i, j]
        if p[2] < p[0] + 10 and p[2] < p[0] + 10:
            dstPx[i, j] = p

dst.save(dstName)
dst.show()
