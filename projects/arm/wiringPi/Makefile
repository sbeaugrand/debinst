# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include ${PROROOT}/makefiles/pro.mk

LIB = wiringPi.a

ifeq ($(shell uname -m),x86_64)
 #CC = aarch64-linux-gnu-gcc
 CC = arm-linux-gnueabihf-gcc
endif

all: build $(LIB)

include $(PROROOT)/makefiles/ccpp.mk

$(LIB): $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^
