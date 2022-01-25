#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file img3gcode.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from PIL import Image

if len(sys.argv) <= 8:
    print(
        'Usage: {} <png> <width-in-mm> <gap-in-px> <margin-in-mm> <smin> <smax> <fmin> <fmax> [-d]'
        .format(sys.argv[0]),
        file=sys.stderr)
    exit(1)
srcName = sys.argv[1]
WIDTH = float(sys.argv[2])
GAP = int(sys.argv[3])
MARGIN = int(sys.argv[4])
SMIN = int(sys.argv[5])  # Puissance du laser 15W en pourmille
SMAX = int(sys.argv[6])
FMIN = int(sys.argv[7])  # Vitesse de deplacement en mm/min
FMAX = int(sys.argv[8])
if len(sys.argv) > 9 and sys.argv[9] == '-d':
    debug = True
else:
    debug = False


# ---------------------------------------------------------------------------- #
## \fn line
# ---------------------------------------------------------------------------- #
def line(image, i, j, pixels):
    global lastVal
    global lastNum
    global lastG0
    global speed

    try:
        sat = image.getpixel((i, image.height - 1 - j))
    except:
        print('i={} j={}'.format(i, j), file=sys.stderr)
        raise

    if lastVal == sat:
        lastNum += 1
    else:
        if debug and lastVal >= 0 and lastVal < 255:
            print('{} v={}'.format(lastNum, lastVal), file=sys.stderr)
        if lastVal < 255:
            if lastG0 != '':
                if speed > 0:
                    speed = 0
                    print('S0')
                print(lastG0)
                lastG0 = ''
            s = SMAX - int(((SMAX - SMIN) * lastVal) / 255)
            if speed != s:
                speed = s
                print('S{}'.format(speed))
            if FMIN != FMAX:
                f = FMIN + int(((FMAX - FMIN) * lastVal) / 255)
                print('G1 X{:.2f} Y{:.2f} F{}'.format(
                    MARGIN + i * WIDTH / image.width,
                    MARGIN + j * HEIGHT / image.height, f))
            else:
                print('G1 X{:.2f} Y{:.2f}'.format(
                    MARGIN + i * WIDTH / image.width,
                    MARGIN + j * HEIGHT / image.height))
        else:
            lastG0 = str('G0 X{:.2f} Y{:.2f} F{}'.format(
                MARGIN + i * WIDTH / image.width,
                MARGIN + j * HEIGHT / image.height, FMAX))
        lastNum = 1
        lastVal = sat
    pixels[i, image.height - 1 - j] = sat


# ---------------------------------------------------------------------------- #
## \fn convert
# ---------------------------------------------------------------------------- #
def convert(image):
    global lastVal

    width, height = image.size
    print('width:  {:4d} px => {:3d} mm'.format(width, int(WIDTH)),
          file=sys.stderr)
    print('height: {:4d} px => {:3d} mm'.format(height, int(HEIGHT)),
          file=sys.stderr)

    dst = Image.new("L", image.size, "white")
    pixels = dst.load()

    dir = 1
    for x in range(int((width - 1) / GAP) * GAP, -1, -GAP):
        lastVal = 255
        if dir == 1:
            i = x
            for y in range(0, width - x):
                line(image, i, y, pixels)
                i += 1
        else:
            i -= 1
            for y in range(y + GAP, -1, -1):
                line(image, i, y, pixels)
                i -= 1
        dir = -dir

    dir = 1
    for y in range(GAP, int((height - 1) / GAP) * GAP, GAP):
        lastVal = 255
        if dir == 1:
            j = y
            for x in range(0, min(height - y, width)):
                line(image, x, j, pixels)
                j += 1
        else:
            j -= 1
            for x in range(x - GAP, -1, -1):
                line(image, x, j, pixels)
                j -= 1
        dir = -dir

    return dst


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
lastVal = 255
lastNum = 0
lastG0 = ''
speed = 0

# Portrait
src = Image.open(srcName)
if src.height < src.width:
    src = src.transpose(method=Image.ROTATE_90)

HEIGHT = src.height * WIDTH / src.width
print('G21')  # Programmation en mm
print('S0')
print('M3')
dst = convert(src)
print('M5')
print('G0 X0 Y0')
print('M2')
dst.show()
