# ---------------------------------------------------------------------------- #
## \file randomColor.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #


def fmt(x):
    """Format a number like PHP print (precision=14)."""
    if isinstance(x, int):
        return str(x)
    s = '%.14G' % x
    if 'E' in s:
        mant, exp = s.split('E')
        if '.' not in mant:
            mant += '.0'
        e = int(exp)
        s = f'{mant}E{"+" if e > 0 else "-"}{abs(e)}'
    return s


class RandomColor:
    # ------------------------------------------------------------------------ #
    ## \fn __init__
    # ------------------------------------------------------------------------ #
    def __init__(self, h):
        self.hue = h

    # ------------------------------------------------------------------------ #
    ## \fn rgb
    # ------------------------------------------------------------------------ #
    def rgb(self, s, v):
        return self.hsvToRgb(self.hue, s, v)

    # ------------------------------------------------------------------------ #
    ## \fn nextRgb
    # ------------------------------------------------------------------------ #
    def nextRgb(self, s, v):
        self.hue += 0.618033988749895
        if self.hue > 1.0:
            self.hue -= 1.0
        return self.hsvToRgb(self.hue, s, v)

    # ------------------------------------------------------------------------ #
    ## \fn hsvToRgb
    ## \note HSV values in [0..1[
    # ------------------------------------------------------------------------ #
    @staticmethod
    def hsvToRgb(h, s, v):
        h_i = int(h * 6)
        f = h * 6 - h_i
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)
        return {
            0: (v, t, p),
            1: (q, v, p),
            2: (p, v, t),
            3: (p, q, v),
            4: (t, p, v),
            5: (v, p, q),
        }[h_i]
