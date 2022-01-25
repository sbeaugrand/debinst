#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file testLaser.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
x0 = 10
y0 = 10


def xy2gcode(code, x, y):
    print('{} X{} Y{}'.format(code, x0 + x, y0 + y))


print('G21')  # Programmation en mm
for x in range(0, 100, 10):
    print('G0 X{} Y{} F{}'.format(x0 + x, y0, (100 - x) * 10))
    print('M3')
    for y in range(0, 100 - x + 50, 10):
        if y >= 100:
            break
        print('S{}'.format((y + 10) * 10))
        xy2gcode('G1', x, y + 10)
    print('M5')
xy2gcode('G0', -x0, -y0)
print('M2')
