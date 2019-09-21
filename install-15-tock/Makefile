# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = tock

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf

$(PROJECT).pdf: build/$(PROJECT).dvi
	dvipdf -dAutoRotatePages=/None $< $@

build/$(PROJECT).dvi: build

build:
	@mkdir $@

build/$(PROJECT).dvi: $(PROJECT).tex
	latex --output-directory build $<

.PHONY: clean
clean:
	@$(RM) build/*.aux build/*.dvi build/*.log *~

.PHONY: mrproper
mrproper: clean
	@$(RM) build/*
	@rmdir build
	@$(RM) *.pdf
