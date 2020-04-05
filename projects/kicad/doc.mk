# ---------------------------------------------------------------------------- #
## \file doc.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARGETS += "| doc"

.PHONY: doc
doc: $(PROJECT).pdf

$(PROJECT).pdf: $(PROJECT).tex\
 kicad/$(PROJECT)Schema.pdf\
 kicad/$(PROJECT)-B_Cu.pdf\
 kicad/$(PROJECT)-F_SilkS.pdf
	@pdflatex --halt-on-error $<
	@$(RM) $(PROJECT).aux $(PROJECT).log
