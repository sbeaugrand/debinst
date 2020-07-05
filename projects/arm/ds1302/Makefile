# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROPATH = arm
include ${PROROOT}/makefiles/pro.mk

CFLAGS = -DROCKPIS
DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
OBJECTS = $(DEVLIB)/ds1302.o rtc.o
CFLAGS += -I$(DEVLIB) -I.

.PHONY: all
all: build build/rtc

GPIO = mraa
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/arm.mk
include $(PROROOT)/arm/wiringPi/wiringPi.mk

build/rtc: $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@

.PHONY: install
install: all
	sudo cp build/rtc /usr/bin/

.PHONY: next
next:
	sudo ./build/rtc `date --date='+1 hour' +%FT%Tw%w`

.PHONY: prev
prev:
	sudo ./build/rtc `date --date='-1 hour' +%FT%Tw%w`

.PHONY: get
get:
	sudo ./build/rtc

include $(PROROOT)/makefiles/tar.mk
