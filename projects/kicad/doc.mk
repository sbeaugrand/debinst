# ---------------------------------------------------------------------------- #
## \file doc.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += kicad/*
TARGETS += "| doc"
TEXINPUTS = $(shell readlink -f $(PROROOT)/kicad):

.PHONY: doc
doc: $(PROJECT).pdf

$(PROJECT).pdf:\
 kicad/$(PROJECT)Schema.pdf\
 kicad/$(PROJECT)-B_Cu.pdf\
 kicad/$(PROJECT)-F_SilkS.pdf

include $(PROROOT)/makefiles/pdf.mk
