# ---------------------------------------------------------------------------- #
## \file doc.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARGETS += "| doc"
TEXINPUTS = $(shell readlink -f $(PROROOT)/kicad):

.PHONY: doc
doc: $(PROJECT).pdf

$(PROJECT).pdf: build $(PROJECT).tex\
 kicad/$(PROJECT)Schema.pdf\
 kicad/$(PROJECT)-B_Cu.pdf\
 kicad/$(PROJECT)-F_SilkS.pdf
	@echo TEXINPUTS=$(TEXINPUTS)
	@cd build && export TEXINPUTS=$(TEXINPUTS) &&\
	 pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ .

.PHONY: livret
livret: livret-$(PROJECT).pdf
livret-$(PROJECT).pdf: $(PROJECT).pdf
	@pdfbook -q -o $@ $< $(P)

.PHONY: portrait
portrait: portrait-$(PROJECT).pdf
portrait-$(PROJECT).pdf: livret-$(PROJECT).pdf
	@pdf90 -q -o $@ $<
