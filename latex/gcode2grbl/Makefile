# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example : make grbl
##                 make gsim
##                 make laser
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk
FONTS = frcr14=frcf14
FEEDR = 12.0# inches/min
include $(PROROOT)/makefiles/gcode.mk

.PHONY: gsim
gsim: grbl-$(PROJECT).ngc
	@gsim $<

.PHONY: laser
laser: laser.ngc
laser.ngc: grbl-$(PROJECT).ngc $(MAKEFILE_LIST)
	@sed\
	 -e 's/M3 S15000.*/S300/'\
	 -e 's/G00 Z0.100 F.*/G00 Z-0.01 F$(FEEDR)\n(begin)/'\
	 -e 's/G00 Z0.100/M5/'\
	 -e 's/G00 Z-0.010/M3/'\
	 -e 's/(M9.*/G0 X0 Y0/'\
	 $< |\
	 sed '/(begin)/,/G01 X0.001 Y0.001/d' |\
	 cat >$@
	@grblminmax.awk $@
