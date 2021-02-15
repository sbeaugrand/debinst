#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gcode.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
scale = 10

with open("build/config.tex") as f:
    for line in f:
        if line.find('sousStylaire') >= 0:
            sousStylaire = float(line.split('{')[1].split('}')[0]) * scale
        if line.find('setlength{\width') >= 0:
            width = float(line.split('{')[2].split('c')[0]) * scale

if width < 300:
    width = 300
    height = 200
    marginY = 10
else:
    width = 600
    height = 300
    marginY = 5
marginX = 5
speed = 200  # Puissance du laser en pourmille (vitesse de rotation)
offsetX = width / 2
offsetY = height - sousStylaire - marginY
first = True

# ---------------------------------------------------------------------------- #
# \fn laserOn
# ---------------------------------------------------------------------------- #
def laserOn():
    print('M3')

# ---------------------------------------------------------------------------- #
# \fn laserOff
# ---------------------------------------------------------------------------- #
def laserOff():
    print('M5')

# ---------------------------------------------------------------------------- #
# \fn dat2gcode
# ---------------------------------------------------------------------------- #
def dat2gcode(file):
    global first
    with open(file) as f:
        for line in f:
            x, y = [float(x) for x in line.split()]
            x = x * scale + offsetX
            y = y * scale + offsetY
            if x >= marginX and x < width - marginX and \
               y >= marginY and y < height - marginY:
                if first:
                    print('G0 X{0:.6f} Y{1:.6f}'.format(x, y))
                    laserOn()
                    first = False
                else:
                    print('G1 X{0:.6f} Y{1:.6f}'.format(x, y))

# ---------------------------------------------------------------------------- #
# \fn xy2gcode
# ---------------------------------------------------------------------------- #
def xy2gcode(code, x, y):
    print('{0} X{1:.6f} Y{2:.6f}'.format(code, x + offsetX, y + offsetY))

# ---------------------------------------------------------------------------- #
# \fn analemme
# ---------------------------------------------------------------------------- #
def analemme(hour):
    global first
    first = True
    # Vitesse de déplacement en mm/min
    if hour.find('_') == -1:
        print('G0 F100')
    else:
        print('G0 F200')
    dat2gcode('build/ete{0}.dat'.format(hour))
    dat2gcode('build/aut{0}.dat'.format(hour))
    dat2gcode('build/hiv{0}.dat'.format(hour))
    dat2gcode('build/pri{0}.dat'.format(hour))
    laserOff()

# ---------------------------------------------------------------------------- #
# \fn main
# ---------------------------------------------------------------------------- #
print('G21')  # Programmation en mm
print('S{0}'.format(speed))

analemme('07')
analemme('07_5')
analemme('08')
analemme('08_5')
analemme('09')
analemme('09_5')
analemme('10')
analemme('10_5')
analemme('11')
analemme('11_5')
analemme('12')
analemme('12_5')
analemme('13')
analemme('13_5')
analemme('14')
analemme('14_5')
analemme('15')
analemme('15_5')
analemme('16')
analemme('16_5')
analemme('17')

xy2gcode('G0', width / 2 - marginX, 0)
laserOn()
xy2gcode('G1', 0, 0)
xy2gcode('G1', 0, sousStylaire)
laserOff()

xy2gcode('G0', 0, 0)
laserOn()
xy2gcode('G1', -width / 2 + marginX, 0)
laserOff()

print('G0 X0 Y0')
print('M2')
