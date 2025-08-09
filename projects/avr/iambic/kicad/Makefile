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
 build/iambic-B_Cu.pdf\
 build/iambic-F_SilkS.pdf\
 build/iambicSchema.pdf\
 iambic.pdf\

CONFIG = $(RDIR)/makefiles/kibot.yaml
TEXINPUTS = $(RDIR)/kicad:
include $(RDIR)/makefiles/kibot.mk
