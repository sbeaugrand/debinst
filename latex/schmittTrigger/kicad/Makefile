# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
RDIR = ../../../cicd

.PHONY: all
all:\
 build\
 build/schmittTriggerSchema.pdf\
 schmittTrigger.pdf\

CONFIG = $(RDIR)/makefiles/kibot.yaml
TEXINPUTS = $(RDIR)/kicad:
include $(RDIR)/makefiles/kibot.mk
