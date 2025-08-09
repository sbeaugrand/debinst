# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
RDIR = ../../../../cicd

.PHONY: all
all:\
 build\
 build/usbtinyisp-B_Cu.pdf\
 build/usbtinyisp-F_SilkS.pdf\
 build/usbtinyispSchema.pdf\
 usbtinyisp.pdf\

CONFIG = $(RDIR)/makefiles/kibot.yaml
TEXINPUTS = $(RDIR)/kicad:
include $(RDIR)/makefiles/kibot.mk
