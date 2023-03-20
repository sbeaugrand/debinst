# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example : make gcode
##            or : make gsim
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk
FONTS = frcr6=frcf6 frcr10=frcf10 frcr14=frcf14
include $(PROROOT)/makefiles/gcode.mk

ZNGCS = $(addprefix z-,$(wildcard [^z]*.ngc))
.PHONY: zoom
zoom: $(ZNGCS)
z-%.ngc: %.ngc
	@echo $@
	@sed -e 's/^#1003 = 0/#1003 = 1/' -e 's/^#1004 = 0/#1004 = 1/' $< >$@

.PHONY: gsim
gsim: z-$(PROJECT).ngc
	@./gsim-launch.py $<
