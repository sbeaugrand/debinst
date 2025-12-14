# ---------------------------------------------------------------------------- #
## \file avr-arduino.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += avr/arduino

ifeq ($(ATMEL),attiny2313)
 VARIANT = tinyx313
endif
ifeq ($(ATMEL),attiny25)
 VARIANT = tinyx5
endif
ifeq ($(ATMEL),attiny45)
 VARIANT = tinyx5
endif
ifeq ($(ATMEL),attiny85)
 VARIANT = tinyx5
endif

BDIR = $(HOME)/data/install-build
ARDUINO = $(BDIR)/ATTinyCore/avr/cores/tiny
PINS_ARDUINO = $(BDIR)/ATTinyCore/avr/variants/$(VARIANT)
CFLAGS += -I$(ARDUINO) -I$(PINS_ARDUINO)

ifeq ($(GPIO),avr)
 OBJECTS += avr_wiring_digital.o
endif

build/avr_%.o: $(ARDUINO)/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
