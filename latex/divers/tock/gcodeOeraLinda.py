# ---------------------------------------------------------------------------- #
## \file gcodeOeraLinda.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from math import *


class gcodeFont:
    def __init__(self, width, sep):
        self.width = width
        self.sep = sep

    def draw(self, x, y, s, a=0):
        pass


class gcodeOeraLinda(gcodeFont):
    def __init__(self, width, sep):
        super().__init__(width, sep)
        self.r = width / 2
        self.x = 0
        self.y = 0
        self.a = 0

    def __semiCircle(self, direction, a, b, init=False):
        x = self.r * cos(self.a + a)
        y = self.r * sin(self.a + a)
        if init:
            print("G0 X{:.2f} Y{:.2f}".format(self.x + x, self.y + y))
            print("M3")
        print("{} X{:.2f} Y{:.2f} I{:.2f} J{:.2f}".format(
            direction,
            self.x + self.r * cos(self.a + b),
            self.y + self.r * sin(self.a + b),
            -x,
            -y,
        ))

    def __lineFromCenter(self, a):
        x = self.r * cos(self.a + a)
        y = self.r * sin(self.a + a)
        print("G1 X{:.2f} Y{:.2f}".format(self.x + x, self.y + y))

    def __lineToCenter(self, a=999):
        if a != 999:
            x = self.r * cos(self.a + a)
            y = self.r * sin(self.a + a)
            print("G0 X{:.2f} Y{:.2f}".format(self.x + x, self.y + y))
            print("M3")
        print("G1 X{:.2f} Y{:.2f}".format(self.x, self.y))

    def __drawChar(self, d):
        if d == '0':
            self.__semiCircle("G3", pi / 2, pi / 2, init=True)
        elif d == '1':
            self.__lineToCenter(pi / 2)
            self.__lineFromCenter(-pi / 2)
        elif d == '2':
            self.__semiCircle("G2", pi * 5 / 6, pi / 6, init=True)
            self.__lineToCenter()
            self.__lineFromCenter(-pi * 5 / 6)
            self.__semiCircle("G3", -pi * 5 / 6, -pi / 6)
        elif d == '3':
            self.__semiCircle("G2", pi / 2, pi / 6, init=True)
            self.__lineToCenter()
            self.__lineFromCenter(-pi / 6)
            self.__semiCircle("G2", -pi / 6, -pi / 2)
        elif d == '4':
            self.__lineToCenter(-pi / 2)
            self.__lineFromCenter(pi / 2)
            self.__semiCircle("G3", pi / 2, pi * 5 / 6)
            self.__lineFromCenter(-pi / 6)
        elif d == '5':
            self.__semiCircle("G3", pi / 6, pi / 2, init=True)
            self.__lineToCenter()
            self.__lineFromCenter(-pi / 6)
            self.__semiCircle("G2", -pi / 6, -pi / 2)
        elif d == '6':
            self.__lineToCenter(pi / 6)
            self.__lineFromCenter(-pi * 5 / 6)
            self.__semiCircle("G3", -pi * 5 / 6, -pi / 6)
            self.__lineToCenter()
        elif d == '7':
            self.__semiCircle("G2", pi * 5 / 6, pi / 6, init=True)
            self.__lineToCenter()
            self.__lineFromCenter(-pi * 5 / 6)
        elif d == '8':
            self.__semiCircle("G3", pi / 6, pi * 5 / 6, init=True)
            self.__lineToCenter()
            self.__lineFromCenter(-pi / 6)
            self.__semiCircle("G2", -pi / 6, -pi * 5 / 6)
            self.__lineToCenter()
            self.__lineFromCenter(pi / 6)
        elif d == '9':
            self.__lineToCenter(-pi * 5 / 6)
            self.__lineFromCenter(pi / 6)
            self.__semiCircle("G3", pi / 6, pi * 5 / 6)
            self.__lineToCenter()
        print("M5")

    def draw(self, x, y, s, a=0):
        self.x = x
        self.y = y
        self.a = a
        w = (self.width + self.sep) * (len(s) - 1)
        self.x -= cos(self.a) * w / 2
        self.y -= sin(self.a) * w / 2
        for c in s:
            self.__drawChar(c)
            self.x += (self.width + self.sep) * cos(self.a)
            self.y += (self.width + self.sep) * sin(self.a)
