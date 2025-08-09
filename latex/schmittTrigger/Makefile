# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = schmittTrigger
PROROOT = ..
DST_EXT = .data# ngspice revision 30
TEXINPUTS = $(shell readlink -f $(PROROOT)/projects/kicad):

include $(PROROOT)/makefiles/livret.mk

$(PROJECT).pdf:\
 build\
 build/$(PROJECT)940Meg.dat\
 build/thresholds940Meg.tex\
 build/thresholds20Meg.tex\
 build/thresholds200Meg.tex\
 build/thresholds2g.tex\

build:
	@mkdir $@

build/%.dat: build/%.data
	@cat $< |\
	 awk 'BEGIN { print "Time V/bascule Time V/diviseur Time V/entree Time V/sortie" } { print $$0 }' >$@

build/%.data: build/%.cir
	ngspice -b -r dummy $<

build/%.cir: %.cir
	@cat $< | sed\
	 -e 's/<dst>/$(PROJECT)$(DST_EXT)/'\
	 | cat >$@

build/thresholds%.tex: build/$(PROJECT)%.dat
	@sed '1d' $< | awk 'BEGIN { l = 4 } {\
		e = $$6;\
		s = $$8;\
		if (s - l > 3 || l - s > 3) {\
			printf "%dV~~~", e * 100;\
			l = s;\
		}\
	}' >$@

include $(PROROOT)/makefiles/tar.mk
