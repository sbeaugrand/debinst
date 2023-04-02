# ---------------------------------------------------------------------------- #
## \file gcodefonts.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
class GcodeFonts:
    def create(name, width, sep):
        if name == '7seg':
            from gcode_7seg import Gcode7seg
            return Gcode7seg(width, sep)
        elif name == 'oeralinda':
            from gcode_oera_linda import GcodeOeraLinda
            return GcodeOeraLinda(width, sep)
