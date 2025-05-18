# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example: cd ../..
##                sudo apt install texlive-fonts-extra
##                ./0install.sh install-op-/install-op-fonts-cursive.sh
##                cd -
##                make gcode
##                make gsim
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk
FONTS = frcr6=frcf6 frcr10=frcf10 frcr14=frcf14
include $(PROROOT)/makefiles/gcode.mk

ZNGCS = $(addprefix z-,$(wildcard [^z]*.ngc))
.PHONY: zoom
zoom: $(ZNGCS)
z-%.ngc: %.ngc $(MAKEFILE_LIST)
	@echo $@
	@sed\
	 -e 's/^#1003 = 0.0139/#1003 = 0.05/'\
	 -e 's/^#1004 = 0.0139/#1004 = 0.05/'\
	 -e 's/^#1001 = 10.0/#1001 = 100.0/' $< >$@

.PHONY: gsim
gsim: z-$(PROJECT).ngc
	@gsim $<
