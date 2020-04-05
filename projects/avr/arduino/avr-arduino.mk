# ---------------------------------------------------------------------------- #
## \file avr-arduino.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += avr/arduino

ifeq ($(ATMEL),attiny2313)
 VARIANT = tinyX313
endif
ifeq ($(ATMEL),attiny45)
 VARIANT = tinyX5
endif

BDIR = $(HOME)/data/install-build
ARDUINO = $(BDIR)/arduino-1.0.6/hardware/arduino/cores/arduino
PINS_ARDUINO = $(BDIR)/ATTinyCore/avr/variants/$(VARIANT)

CFLAGS +=\
 -I$(ARDUINO) -I$(PINS_ARDUINO) -I$(PROROOT)/avr/arduino -D$(VARIANT)

ifeq ($(GPIO),avr)
 OBJECTS += avr_wiring_digital.o
endif

build/avr_%.o: $(ARDUINO)/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
