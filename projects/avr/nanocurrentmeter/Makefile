# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny45&LOW=E2
##       vi ATTinyCore/avr/cores/tiny/wiring_analog.c +/badCall  # comment
##       make hex
##       make flash
##       stty -F /dev/ttyUSB1 -icrnl
##       cat /dev/ttyUSB1
# ---------------------------------------------------------------------------- #
ATMEL = attiny45
CFLAGS += -ffunction-sections
CFLAGS += -DF_CPU=8000000UL
LFUSE = 0xe2

BDIR = /data/install-build
CORE = $(BDIR)/ATTinyCore/avr/cores/tiny
PINS = $(BDIR)/ATTinyCore/avr/variants/tinyx5
CFLAGS += -I$(CORE) -I$(PINS)
CPPCHECKINC = -I$(CORE) -I$(PINS) --force

CXXFLAGS := $(CFLAGS)
CXXFLAGS += -DSOFT_TX_ONLY
CXXFLAGS += -Wno-restrict

OBJECTS += $(PROJECT).o
OBJECTS += core_TinySoftwareSerial.o
OBJECTS += core_Print.o
OBJECTS += core_WString.o
OBJECTS += core_wiring_digital.o
OBJECTS += core_wiring_analog.o
OBJECTS += core_wiring.o
OBJECTS += core_main.o
include ../../makefiles/avr.mk

build/core_%.o: $(CORE)/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

build/core_%.o: $(CORE)/%.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
