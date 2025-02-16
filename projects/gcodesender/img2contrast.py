#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file img2contrast.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from PIL import Image

if len(sys.argv) <= 2:
    print(f'Usage: {sys.argv[0]} <png> <contrast.png>'
          f' [(<threshold1> <color1>)... 0 0]', file=sys.stderr)
    exit(1)
srcName = sys.argv[1]
dstName = sys.argv[2]

# Grayscale
src = Image.open(srcName).convert('L')
dst = Image.new("L", src.size)
srcPx = src.load()
dstPx = dst.load()

# Contrast
m = 255
n = 0
for j in range(0, dst.height):
    for i in range(0, dst.width):
        m = min(m, srcPx[i, j])
        n = max(n, srcPx[i, j])

for j in range(0, dst.height):
    for i in range(0, dst.width):
        p = srcPx[i, j]
        dstPx[i, j] = int((p - m) * 255 / (n - m))

# Posterize
if len(sys.argv) > 3:
    threshold = [int(i) for i in sys.argv[3::2]]
    color = [int(i) for i in sys.argv[4::2]]
    for j in range(0, dst.height):
        for i in range(0, dst.width):
            p = dstPx[i, j]
            for c, t in enumerate(threshold):
                if p >= t:
                    dstPx[i, j] = color[c]
                    break
else:
    for j in range(0, dst.height):
        for i in range(0, dst.width):
            p = dstPx[i, j]
            # 16 colors + white
            if p < 255:
                dstPx[i, j] = p & 0xF0

dst.save(dstName)
dst.show()
