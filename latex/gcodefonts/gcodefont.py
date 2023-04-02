# ---------------------------------------------------------------------------- #
## \file gcodefont.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from abc import ABC, abstractmethod


class GcodeFont(ABC):
    def __init__(self, width, sep):
        self.width = width
        self.height = width
        self.sep = sep

    @abstractmethod
    def draw(self, s, x, y, a=0):
        pass
