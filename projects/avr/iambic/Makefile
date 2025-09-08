# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny45&LOW=E2
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk
PROPATH = avr

ATMEL = attiny45
LFUSE = 0xe2# oscillateur interne 8 MHz, sans CKDIV8
include $(PROROOT)/makefiles/avr.mk

include $(PROROOT)/makefiles/tar.mk
