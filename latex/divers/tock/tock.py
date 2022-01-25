#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file tock.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from math import *
from scipy.optimize import fsolve
from gcodeOeraLinda import *

RPLATEAU = 150
n = int(sys.argv[1])
if n == 4:
    l = 220
    circleRadius = 6
    quinzeAngle = radians(26.9 / 2)
    font = gcodeOeraLinda(width=4, sep=1)
elif n == 6:
    l = 230
    circleRadius = 5
    quinzeAngle = radians(35.3 / 2)
    font = gcodeOeraLinda(width=3, sep=1)


def f(x):
    h = (1 + 0.5 / cos(pi / n)) * l * tan(pi / n / 2) + x * tan(pi / n)
    r = sqrt(h * h + x * x)
    y = r * sin(pi / 2 * (31 / 17 - 28 / 17 / n) +
                3 / 17 * asin(x / r)) - (l / 2 + x) * tan(pi / n)
    return y


ecart = fsolve(f, -50)[0]
print("\\ecart={:.6f}cm".format(ecart / 10), file=sys.stderr)

h = (1 + 0.5 / cos(pi / n)) * l * tan(pi / n / 2) + ecart * tan(pi / n)
radius = sqrt(h * h + ecart * ecart)
print("\\rayon={:.6f}cm".format(radius / 10), file=sys.stderr)

ainit = pi / n + asin(ecart / radius)
print("\\def\\ainit{:.6f}".format(degrees(ainit)), file=sys.stderr)

aincr = (pi - 2 * ainit) / 17
print("\\def\\aincr{:.6f}".format(degrees(aincr)), file=sys.stderr)

hinit = (l / 2 + ecart) / cos(pi / n) - l / 2 / cos(pi / n / 2)
print("\\hinit={:.6f}cm".format(hinit / 10), file=sys.stderr)

hincr = radius * tan(aincr)
print("\\hincr={:.6f}cm".format(hincr / 10), file=sys.stderr)

quinze = l / 2 * sin(pi / n / 4)
print("\\quinze={:.6f}cm".format(quinze / 10), file=sys.stderr)

yorig = -(l / 2 + ecart) / cos(pi / n)
print("\\yorig={:.6f}cm".format(yorig / 10), file=sys.stderr)


def drawWithCartesian(branchAngle, u, v, num, numAngle):
    x = RPLATEAU + u * cos(branchAngle) - v * sin(branchAngle)
    y = RPLATEAU + u * sin(branchAngle) + v * cos(branchAngle)
    if num == 0:
        num = 18
        print("S500")
    print("G0 X{:.2f} Y{:.2f}".format(x + circleRadius, y))
    print("M3")
    print("G3 X{:.2f} Y{:.2f} I{}".format(x + circleRadius, y, -circleRadius))
    print("M5")
    print("(n={},a={:.1f})".format(num, degrees(branchAngle + numAngle)))
    font.draw(x, y, "{}".format(num), branchAngle + numAngle)
    if num == 18:
        print("S300")


def drawWithPolar(branchAngle, angle, num, numAngle):
    x = radius * cos(angle)
    y = radius * sin(angle) + yorig
    drawWithCartesian(branchAngle, x, y, num, numAngle)


def drawBranch(branchAngle):
    a = ainit
    for i in range(0, 7):
        drawWithPolar(branchAngle, a, i, a)
        a += aincr
    drawWithPolar(branchAngle, a, 7, pi / n)
    a += aincr * 4
    for i in range(8, 15):
        drawWithPolar(branchAngle, a, i, a - pi)
        a += aincr
    drawWithCartesian(branchAngle, quinze, hinit + yorig, 15, quinzeAngle)
    drawWithCartesian(branchAngle, 0, hinit - hincr + yorig, 16, 0)
    y = yorig + hinit + hincr
    for i in range(17, 21):
        drawWithCartesian(branchAngle, 0, y, i, 0)
        y += hincr
    drawWithCartesian(branchAngle, -quinze, hinit + yorig, 17, -quinzeAngle)


print("(margin={:.1f}mm)".format(RPLATEAU -
                                 (-yorig - hinit + hincr + circleRadius)))
print("G21")
print("S300")
print("G0 F300")
for a in range(0, 360, int(360 / n)):
    drawBranch(radians(a))
print("G0 X0 Y0")
print("M2")
