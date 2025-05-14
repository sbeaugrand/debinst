# ---------------------------------------------------------------------------- #
## \file gcode.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PDFLATEX = pdflatex --halt-on-error ../$(PROJECT).tex
PDF2GCODE = $(shell which pdftogcode.sh)
GCODE2GRBL = $(shell which gcode2grbl.awk)
GRBLSIMPL = $(shell which grblsimplify.sh)
FEEDR ?= 10.0# inches/min
TARDEPEND +=\
 gcodefonts/*.py\
 gcodefonts/Makefile\
 bin/pdftogcode.sh\
 bin/gcode2grbl.awk\
 bin/grblsimplify.sh\

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf
$(PROJECT).pdf: $(PROJECT).tex
	@mkdir -p build && cd build && TEXINPUTS="../font-n:" $(PDFLATEX)
	@mv build/$@ .

.PHONY: gcode
gcode: $(PROJECT).ngc
$(PROJECT).ngc: $(PROJECT).pdf $(PDF2GCODE)
	@$(PDF2GCODE) $< $(FONTS)

.PHONY: grbl
grbl: grbl-$(PROJECT).ngc
grbl-$(PROJECT).ngc: build/grbl-$(PROJECT).ngc $(GRBLSIMPL)
	@$(GRBLSIMPL) $< >$@
build/grbl-$(PROJECT).ngc: $(PROJECT).ngc $(GCODE2GRBL)
	@sed 's/^#1001 = 10.0/#1001 = $(FEEDR)/' $< | $(GCODE2GRBL) >$@

.PHONY: stick
stick: stick.ngc
stick.ngc: build/$(PROJECT).pdf.ps
	@pstoedit -q -pta -f gcode $< $@
	@sed -i 's/G01 Z/G00 Z/' $@
build/$(PROJECT).pdf.ps: build/$(PROJECT).pdf
	@pdftops $< $@
build/$(PROJECT).pdf: $(PROJECT).tex
	@mkdir -p build && cd build && TEXINPUTS="../font-g:" $(PDFLATEX)

.PHONY: ps-stick
ps-stick: ps-stick.ngc
ps-stick.ngc: build/$(PROJECT).ps
	@pstoedit -q -pta -f gcode $< $@
	@sed -i 's/G01 Z/G00 Z/' $@
build/$(PROJECT).ps: build/$(PROJECT).dvi
	dvips -o $@ $<
build/$(PROJECT).dvi: $(PROJECT).tex
	@mkdir -p build && cd build &&\
	 TEXINPUTS="../font-g:" latex --halt-on-error ../$(PROJECT).tex

.PHONY: clean
clean:
	@$(RM) build/*.*

.PHONY: mrproper
mrproper: clean
	@test ! -d build || rmdir build
	@$(RM) $(PROJECT).pdf *.ngc
