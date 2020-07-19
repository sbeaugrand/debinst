# ---------------------------------------------------------------------------- #
## \file livret.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/livret.mk

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf

%.pdf: build %.tex
	@cd build && pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ .

build:
	@mkdir $@

.PHONY: livret
livret: livret-$(PROJECT).pdf
livret-$(PROJECT).pdf: $(PROJECT).pdf
	@pdfbook -q -o $@ $< $(P)

.PHONY: portrait
portrait: portrait-$(PROJECT).pdf
portrait-$(PROJECT).pdf: livret-$(PROJECT).pdf
	@pdf90 -q -o $@ $<

.PHONY: clean
clean:
	@$(RM) build/*.*

.PHONY: mrproper
mrproper: clean
	@rmdir build
	@$(RM) $(PROJECT).pdf
