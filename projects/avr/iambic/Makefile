# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk
PROPATH = avr

ATMEL = attiny45
LFUSE = 0xe2# oscillateur interne 8 MHz, sans CKDIV8
include $(PROROOT)/makefiles/avr.mk

include $(PROROOT)/kicad/doc.mk

include $(PROROOT)/makefiles/tar.mk
