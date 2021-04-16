# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../../../projects
include $(PROROOT)/makefiles/pro.mk
include $(PROROOT)/kicad/doc.mk

build:
	@mkdir $@

.PHONY: landscape
landscape: landscape.pdf
landscape.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $<
