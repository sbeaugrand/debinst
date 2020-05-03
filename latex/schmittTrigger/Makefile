# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = schmittTrigger
PROROOT = ..
DST_EXT = .data# ngspice revision 30

.PHONY: all
all: $(PROJECT).pdf

$(PROJECT).pdf: $(PROJECT).tex build build/$(PROJECT).dat\
 kicad/$(PROJECT)Schema.pdf
	pdflatex --halt-on-error $<
	@$(RM) $(PROJECT).aux $(PROJECT).log

build:
	@mkdir $@

%.dat: %.data
	@cat $< |\
	 awk 'BEGIN { print "Time V/bascule Time V/diviseur Time V/entree Time V/sortie" } { print $$0 }' >$@

%.data: %.net
	@ngspice -b -r dummy $<

build/$(PROJECT).net: $(PROJECT).net
	@cat $< | sed\
	 -e 's/<dst>/$(PROJECT)$(DST_EXT)/'\
	 | cat >$@

include $(PROROOT)/makefiles/tar.mk
