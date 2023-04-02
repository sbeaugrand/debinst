# ---------------------------------------------------------------------------- #
## \file gcode_oera_linda.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from math import *
from gcodefont import *


class GcodeOeraLinda(GcodeFont):
    def __init__(self, width, sep):
        super().__init__(width, sep)
        self.r = width / 2
        self.x = 0
        self.y = 0
        self.a = 0

    def __semi_circle(self, direction, a, b, init=False):
        x = self.r * cos(self.a + a)
        y = self.r * sin(self.a + a)
        if init:
            print("G0 X{:.3f} Y{:.3f}".format(self.x + x, self.y + y))
            print("M3")
        print("{} X{:.3f} Y{:.3f} I{:.3f} J{:.3f}".format(
            direction,
            self.x + self.r * cos(self.a + b),
            self.y + self.r * sin(self.a + b),
            -x,
            -y,
        ))

    def __line_from_center(self, a):
        x = self.r * cos(self.a + a)
        y = self.r * sin(self.a + a)
        print("G1 X{:.3f} Y{:.3f}".format(self.x + x, self.y + y))

    def __line_to_center(self, a=999):
        if a != 999:
            x = self.r * cos(self.a + a)
            y = self.r * sin(self.a + a)
            print("G0 X{:.3f} Y{:.3f}".format(self.x + x, self.y + y))
            print("M3")
        print("G1 X{:.3f} Y{:.3f}".format(self.x, self.y))

    def __draw_char(self, d):
        if d == '0':
            self.__semi_circle("G3", pi / 2, -pi / 2, init=True)
            self.__semi_circle("G3", -pi / 2, pi / 2)
        elif d == '1':
            self.__line_to_center(pi / 2)
            self.__line_from_center(-pi / 2)
        elif d == '2':
            self.__semi_circle("G2", pi * 5 / 6, pi / 6, init=True)
            self.__line_to_center()
            self.__line_from_center(-pi * 5 / 6)
            self.__semi_circle("G3", -pi * 5 / 6, -pi / 6)
        elif d == '3':
            self.__semi_circle("G2", pi / 2, pi / 6, init=True)
            self.__line_to_center()
            self.__line_from_center(-pi / 6)
            self.__semi_circle("G2", -pi / 6, -pi / 2)
        elif d == '4':
            self.__line_to_center(-pi / 2)
            self.__line_from_center(pi / 2)
            self.__semi_circle("G3", pi / 2, pi * 5 / 6)
            self.__line_from_center(-pi / 6)
        elif d == '5':
            self.__semi_circle("G3", pi / 6, pi / 2, init=True)
            self.__line_to_center()
            self.__line_from_center(-pi / 6)
            self.__semi_circle("G2", -pi / 6, -pi / 2)
        elif d == '6':
            self.__line_to_center(pi / 6)
            self.__line_from_center(-pi * 5 / 6)
            self.__semi_circle("G3", -pi * 5 / 6, -pi / 6)
            self.__line_to_center()
        elif d == '7':
            self.__semi_circle("G2", pi * 5 / 6, pi / 6, init=True)
            self.__line_to_center()
            self.__line_from_center(-pi * 5 / 6)
        elif d == '8':
            self.__semi_circle("G3", pi / 6, pi * 5 / 6, init=True)
            self.__line_to_center()
            self.__line_from_center(-pi / 6)
            self.__semi_circle("G2", -pi / 6, -pi * 5 / 6)
            self.__line_to_center()
            self.__line_from_center(pi / 6)
        elif d == '9':
            self.__line_to_center(-pi * 5 / 6)
            self.__line_from_center(pi / 6)
            self.__semi_circle("G3", pi / 6, pi * 5 / 6)
            self.__line_to_center()
        print("M5")

    def draw(self, s, x, y, a=0):
        self.x = x + self.width / 2
        self.y = y + self.height / 2
        self.a = a
        w = (self.width + self.sep) * (len(s) - 1)
        self.x -= cos(self.a) * w / 2
        self.y -= sin(self.a) * w / 2
        for c in s:
            self.__draw_char(c)
            self.x += (self.width + self.sep) * cos(self.a)
            self.y += (self.width + self.sep) * sin(self.a)
