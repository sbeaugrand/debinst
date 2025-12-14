# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny85&LOW=E2
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk
PROPATH = avr
TARGETS += "| tests"
CPPCHECKINC = -I$(PROROOT) -I.

ATMEL = attiny85
ADC = avr
GPIO = avr
OBJECTS = fftAlarm.o fix_fft.o
CFLAGS = -DF_CPU=8000000UL -D$(VARIANT)
LFUSE = 0xe2# oscillateur interne 8 MHz, sans CKDIV8
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/avr.mk
CFLAGS += -O1# fix undefined reference to inline FIX_MPY

PHONY: tests
tests:
	@$(MAKE) --no-print-directory -f tests.mk

TARDEPEND += x11/*
TARDEPEND += debug/*
include $(PROROOT)/makefiles/tar.mk
