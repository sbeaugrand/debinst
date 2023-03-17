# ---------------------------------------------------------------------------- #
## \file gcode.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PDFLATEX = pdflatex --halt-on-error ../$(PROJECT).tex
PDF2GCODE = $(shell which pdftogcode.sh)

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf
$(PROJECT).pdf: $(PROJECT).tex
	@mkdir -p build && cd build && TEXINPUTS="../font-n:" $(PDFLATEX)
	@mv build/$@ .
.PHONY: gcode
gcode: $(PROJECT).ngc
$(PROJECT).ngc: $(PROJECT).pdf $(PDF2GCODE)
	@$(PDF2GCODE) $< $(FONT)

.PHONY: stick
stick: stick.ngc
stick.ngc: build/$(PROJECT).pdf
	@pstoedit -q -pta -f gcode $< $@
	@sed -i 's/G01 Z/G00 Z/' $@
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
