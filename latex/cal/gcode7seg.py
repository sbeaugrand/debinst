# ---------------------------------------------------------------------------- #
## \file gcode7seg.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
class gcodeFont:
    def __init__(self, width, sep):
        self.width = width
        self.sep = sep

    def draw(s):
        pass

class gcode7seg(gcodeFont):
    def __init__(self, width, sep):
        super().__init__(width, sep)

    def __uv2gcode(self, code, x, y):
        print('{} X{:.2f} Y{:.2f}'.format(code, x, y))

    def __segH2gcode(self, x, y):
        self.__uv2gcode('G0', x, y)
        print('M3')
        self.__uv2gcode('G1', self.width / 8, self.width / 8)
        self.__uv2gcode('G1', self.width - self.width / 4, 0)
        self.__uv2gcode('G1', self.width / 8, -self.width / 8)
        self.__uv2gcode('G1', -self.width / 8, -self.width / 8)
        self.__uv2gcode('G1', -self.width + self.width / 4, 0)
        self.__uv2gcode('G1', -self.width / 8, self.width / 8)
        print('M5')
        self.__uv2gcode('G0', -x, -y)

    def __segV2gcode(self, x, y):
        self.__uv2gcode('G0', x, y)
        print('M3')
        self.__uv2gcode('G1', self.width / 8, self.width / 8)
        self.__uv2gcode('G1', 0, self.width - self.width / 4)
        self.__uv2gcode('G1', -self.width / 8, self.width / 8)
        self.__uv2gcode('G1', -self.width / 8, -self.width / 8)
        self.__uv2gcode('G1', 0, -self.width + self.width / 4)
        self.__uv2gcode('G1', self.width / 8, -self.width / 8)
        print('M5')
        self.__uv2gcode('G0', -x, -y)

    def __digit2gcode(self, d):
        if d != 1 and d != 4:
            self.__segH2gcode(0, self.width * 2)
        if d != 5 and d != 6:
            self.__segV2gcode(self.width, self.width)
        if d != 2:
            self.__segV2gcode(self.width, 0)
        if d != 1 and d != 4 and d != 7:
            self.__segH2gcode(0, 0)
        if d == 0 or d == 2 or d == 6 or d == 8:
            self.__segV2gcode(0, 0)
        if d != 1 and d != 2 and d != 3 and d != 7:
            self.__segV2gcode(0, self.width)
        if d != 0 and d != 1 and d != 7:
            self.__segH2gcode(0, self.width)

    def __drawChar(self, c):
        n = ord(c) - ord('0')
        if n < 0 or n > 9:
            return 0
        self.__digit2gcode(n)
        self.__uv2gcode('G0', self.width + self.sep, 0)
        return 1

    def draw(self, s):
        print('({})'.format(s))
        print('G91')
        l = 0
        for c in s:
            l += self.__drawChar(c)
        #self.__uv2gcode('G0', -l * (self.width + self.sep), 0)
        print('G90')
