# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example : make grbl
##            or : make gsim
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk
FONTS = frcr14=frcf14
FEEDR = 20.0# inches/min
include $(PROROOT)/makefiles/gcode.mk

.PHONY: gsim
gsim: grbl-$(PROJECT).ngc
	@gsim $<
