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

RCSwitch.cpp: rc-switch
	@ln -sf rc-switch/RCSwitch.cpp $@

ReceiveDemo_Simple.cpp: rc-switch
	@ln -sf rc-switch/examples/ReceiveDemo_Simple/ReceiveDemo_Simple.ino $@

rc-switch:
	@git clone https://github.com/sui77/rc-switch.git

test:
	@stty -F /dev/ttyACM0 9600
	@cat /dev/ttyACM0
