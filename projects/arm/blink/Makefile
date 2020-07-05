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
OBJECTS = blink.o

.PHONY: all
all: build build/$(PROJECT)

GPIO = mraa
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/arm.mk
include $(PROROOT)/arm/wiringPi/wiringPi.mk

build/$(PROJECT): $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@

include $(PROROOT)/makefiles/tar.mk
