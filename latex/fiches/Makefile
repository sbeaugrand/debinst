# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = fiches
PROROOT = ../..

include $(PROROOT)/makefiles/livret.mk
%.pdf: build %.tex

$(PROJECT).pdf:\
 $(PROROOT)/projects/avr/iambic/iambic.pdf\
 $(PROROOT)/latex/geiger/geiger.pdf\
 $(PROROOT)/latex/schmittTrigger/schmittTrigger.pdf\
 $(PROROOT)/projects/avr/fftAlarm/fftAlarm.pdf\

	@#pdfjam -q -o $@ $< '{}' $^
	@pdfjam -q -o $@ $^
