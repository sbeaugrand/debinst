# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROPATH = arm
include ${PROROOT}/makefiles/pro.mk
SERVICE = rtc

DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
OBJECTS = $(DEVLIB)/ds1302.o $(SERVICE).o
CFLAGS += -I$(DEVLIB) -I. -DNDEBUG

.PHONY: all
all: build build/$(SERVICE)

GPIO = mraa
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/arm.mk
include $(PROROOT)/arm/wiringPi/wiringPi.mk

build/$(SERVICE): $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@

.PHONY: reinstall
reinstall: all
	@sudo cp build/$(SERVICE) /usr/sbin/

.PHONY: next
next:
	sudo ./build/$(SERVICE) `date --date='+1 hour' +%FT%Tw%w`

.PHONY: prev
prev:
	sudo ./build/$(SERVICE) `date --date='-1 hour' +%FT%Tw%w`

.PHONY: get
get:
	sudo ./build/$(SERVICE)

include $(PROROOT)/makefiles/service.mk
include $(PROROOT)/makefiles/tar.mk
