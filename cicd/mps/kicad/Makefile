# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TEXINPUTS = ../../../kicad:

.PHONY: all
all:\
 remoteControl-B_Cu.pdf\
 remoteControl-F_SilkS.pdf\
 remoteControlSchema.pdf\
 remoteControl.pdf

%.pdf: %.tex
	@echo TEXINPUTS=$(TEXINPUTS)
	@mkdir -p build && cd build && export TEXINPUTS=$(TEXINPUTS) &&\
	 pdflatex --halt-on-error ../$<
	@mv build/$@ .

include ../../makefiles/kibot.mk
