# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..

BDIR     = $(HOME)/data/install-build
HARDWARE = $(BDIR)/arduino-1.0.6/hardware
ARDUINO  = $(HARDWARE)/arduino

OBJECTS =\
 $(ARDUINO)/cores/arduino/wiring.o\
 $(ARDUINO)/cores/arduino/wiring_digital.o\
 $(ARDUINO)/cores/arduino/Print.o\
 $(ARDUINO)/cores/arduino/HardwareSerial.o\
 $(HARDWARE)/../libraries/SoftwareSerial/SoftwareSerial.o\
 serial.o

CXXFLAGS = -I$(HARDWARE)/../libraries/SoftwareSerial
include $(PROROOT)/makefiles/arduino.mk
