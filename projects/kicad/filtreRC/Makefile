# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: all
all: build plot

build:
	@mkdir $@

.PHONY: plot
plot: build/filtreRC.data
	@cat $< | ./filtreRC.py

build/filtreRC.data: filtreRC.cir filtreRC.py
	@cd build && ngspice -b -r dummy ../$<
