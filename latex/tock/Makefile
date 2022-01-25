# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk

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

.PHONY: gcode
gcode: tock4.nc tock6.nc tock.py gcodeOeraLinda.py
	@./tock.py 4 >tock4.nc
	@echo
	@grep -H 'margin' tock4.nc
	@echo
	@./tock.py 6 >tock6.nc
	@echo
	@grep -H 'margin' tock6.nc
	@echo

.PHONY: clean
clean:
	@$(RM) build/*.aux build/*.dvi build/*.log *~

.PHONY: mrproper
mrproper: clean
	@$(RM) build/*
	@rmdir build
	@$(RM) *.pdf

include $(PROROOT)/makefiles/tar.mk
