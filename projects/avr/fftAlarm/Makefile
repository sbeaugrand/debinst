# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk
PROPATH = avr
TARGETS += "| tests"

ATMEL = attiny85
VARIANT = tinyX5
ADC = avr
GPIO = avr
OBJECTS = fftAlarm.o fix_fft.o
CFLAGS = -DF_CPU=8000000UL -std=c99
LFUSE = 0xe2# oscillateur interne 8 MHz, sans CKDIV8
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/avr.mk

PHONY: tests
tests:
	@$(MAKE) --no-print-directory -f tests.mk

include $(PROROOT)/kicad/doc.mk
TARDEPEND += x11/*
TARDEPEND += debug/*
include $(PROROOT)/makefiles/tar.mk
