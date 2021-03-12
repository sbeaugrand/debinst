#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file testLaser.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
def xy2gcode(code, x, y):
    print('{} X{} Y{}'.format(code, x, y))

print('G21')  # Programmation en mm
print('S300')  # Puissance du laser en pourmille (vitesse de rotation)
print('G0 F300')  # Vitesse de déplacement en mm/min
print('M3')
xy2gcode('G1', 100, 0)
xy2gcode('G1', 100, 100)
print('M5')
print('G91')
xy2gcode('G0', 0, -5)
ix = -10
for f in range(450, 0, -50):
    print('G0 F{}'.format(f))
    print('M3')
    iy = -10
    for s in range(50, 550, 50):
        print('S{}'.format(s))
        xy2gcode('G1', ix, iy)
        iy = -iy
    print('M5')
    ix = -ix
    xy2gcode('G0', 0, -10)
print('G90')
xy2gcode('G0', 0, 0)
print('S200')
print('G0 F200')
print('M3')
xy2gcode('G1', 0, 100)
xy2gcode('G1', 100, 100)
xy2gcode('G1', 100, 0)
xy2gcode('G1', 0, 0)
print('M5')
print('M2')
