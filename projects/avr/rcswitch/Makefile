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
 $(ARDUINO)/cores/arduino/Print.o\
 $(ARDUINO)/cores/arduino/HardwareSerial.o\
 $(ARDUINO)/cores/arduino/WInterrupts.o\
 RCSwitch.o\
 ReceiveDemo_Simple.o

CXXFLAGS = -Irc-switch
include $(PROROOT)/makefiles/arduino.mk

RCSwitch.cpp:
	@git clone https://github.com/sui77/rc-switch.git
