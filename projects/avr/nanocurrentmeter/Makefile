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
FLAGS = -DF_CPU=8000000UL
LFUSE = 0xe2
PROG ?= avrisp -b 19200 -P /dev/ttyUSB0# ArduinoISP

ARDUINO = /data/install-build/ATTinyCore
CORE    = $(ARDUINO)/avr/cores/tiny
PINS    = $(ARDUINO)/avr/variants/tinyx5
FLAGS  += -I$(CORE) -I$(PINS)

CPPCHECKINC = -I$(CORE) -I$(PINS) -DADCSRA

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
include ../../../cicd/makefiles/avr.mk
