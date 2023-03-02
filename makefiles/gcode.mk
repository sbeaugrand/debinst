# ---------------------------------------------------------------------------- #
## \file gcode.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/gcode.mk

PDFLATEX = pdflatex --halt-on-error ../$(PROJECT).tex

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf
$(PROJECT).pdf: build $(PROJECT).tex
	@cd build && TEXINPUTS="../font-n:" $(PDFLATEX)
	@mv build/$@ .

build:
	@mkdir $@

.PHONY: gcode
gcode: $(PROJECT).nc
$(PROJECT).nc: build/$(PROJECT).pdf
	@pstoedit -pta -f gcode $< $@
	@sed -i 's/G01 Z/G00 Z/' $@

build/$(PROJECT).pdf: build $(PROJECT).tex
	@cd build && TEXINPUTS="../font-g:" $(PDFLATEX)

.PHONY: ps-gcode
ps-gcode: ps-$(PROJECT).nc
ps-$(PROJECT).nc: build/$(PROJECT).ps
	@pstoedit -pta -f gcode $< $@
	@sed -i 's/G01 Z/G00 Z/' $@

build/$(PROJECT).ps: build/$(PROJECT).dvi
	dvips -o $@ $<

build/$(PROJECT).dvi: build $(PROJECT).tex
	@cd build && TEXINPUTS="../font-g:" latex --halt-on-error ../$(PROJECT).tex
