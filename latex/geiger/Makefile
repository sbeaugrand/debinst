# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
RDIR = ../../cicd

.PHONY: all
all:\
 build\
 build/geiger-B_Cu.pdf\
 build/geiger-F_SilkS.pdf\
 build/geigerSchema.pdf\
 geiger.pdf\

CONFIG = $(RDIR)/makefiles/kibot.yaml
TEXINPUTS = $(RDIR)/kicad:
include $(RDIR)/makefiles/kibot.mk

PROJECT = geiger
PROROOT = ..
include $(PROROOT)/makefiles/tar.mk
