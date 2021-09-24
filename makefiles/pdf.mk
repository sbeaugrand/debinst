# ---------------------------------------------------------------------------- #
## \file pdf.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/pdf.mk
TARGETS += "| livret | portrait | extrait"

.SUFFIXES:

%.pdf: build %.tex
	@echo TEXINPUTS=$(TEXINPUTS)
	@cd build && export TEXINPUTS=$(TEXINPUTS) &&\
	 pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ .

.PHONY: livret
livret: livret-$(PROJECT).pdf
livret-$(PROJECT).pdf: $(PROJECT).pdf
	@pdfxup -b -kbb -ow -o $@ $<

.PHONY: portrait
portrait: portrait-$(PROJECT).pdf
portrait-$(PROJECT).pdf: livret-$(PROJECT).pdf
	@pdfjam -q --angle 90 -o $@ $<

.PHONY: extrait
extrait: extrait-$(PROJECT).pdf
extrait-$(PROJECT).pdf: $(PROJECT).pdf
	@pdjam -q -o $@ $< $(P)
