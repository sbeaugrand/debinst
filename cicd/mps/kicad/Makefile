# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
RDIR = ../..

.PHONY: all
all:\
 build\
 build/remoteControl-B_Cu.pdf\
 build/remoteControl-F_SilkS.pdf\
 build/remoteControlSchema.pdf\
 remoteControlSchema.svg\
 remoteControlPcb.svg\
 remoteControl.pdf\

%Schema.svg: build/%-darklight.svg
	$(call scale,2,$@,$<)

%Pcb.svg: build/%-pcb.svg
	$(call scale,2,$@,$<)

TEXINPUTS = $(RDIR)/kicad:
include $(RDIR)/makefiles/kibot.mk
