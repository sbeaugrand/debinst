# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.SUFFIXES:

.PHONY: all
all:

.PHONY: flash
flash:
	cd $$HOME/data/install-build/Marlin/Marlin &&\
	 avrdude -c wiring -p m2560 -D -P /dev/ttyACM0 -U flash:w:Marlin.ino.hex
