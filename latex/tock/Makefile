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
gcode: tock4.nc tock6.nc
tock4.nc: tock.py
	@./$< 4 >$@
	@echo
	@grep -H 'margin' $@
	@echo
tock6.nc: tock.py
	@./$< 6 >$@
	@echo
	@grep -H 'margin' $@
	@echo

.PHONY: gvalidate
gvalidate: tock4.nc tock6.nc
	@gvalidate -s tock4.nc || echo "(tock4.nc)"
	@gvalidate -s tock6.nc || echo "(tock6.nc)"
	@$(RM) EEPROM.DAT

.PHONY: clean
clean:
	@$(RM) build/*.aux build/*.dvi build/*.log *~

.PHONY: mrproper
mrproper: clean
	@$(RM) build/*
	@rmdir build
	@$(RM) *.pdf

TARDEPEND += gcodefonts/*.py gcodefonts/Makefile
include $(PROROOT)/makefiles/tar.mk
