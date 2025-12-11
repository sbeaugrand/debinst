# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROPATH = arm
include $(PROROOT)/makefiles/pro.mk
SERVICE = rtc
DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
CPPCHECKINC = -I$(DEVLIB)

ifeq ($(shell uname -m),x86_64)
 #XC = arm-linux-gnueabihf
 XC = aarch64-linux-gnu
 ifneq ($(XC),)
  XCVER ?= 14
  XCDIR ?= /data
  SYSROOT = $(XCDIR)/$(XC)-$(XCVER)
  CC = $(XC)-gcc
  CXX = $(XC)-g++
  CFLAGS = --sysroot=$(SYSROOT) -nostdinc\
   -I${SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include\
   -I$(SYSROOT)/usr/include/$(XC)\

  CXXFLAGS = --sysroot=$(SYSROOT) -nostdinc\
   -I${SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include\
   -I$(SYSROOT)/usr/include/$(XC)\

  CFLAGS +=\
   -isystem $(SYSROOT)/usr/include\
   -isystem $(SYSROOT)/usr/local/include\

  CXXFLAGS +=\
   -isystem $(SYSROOT)/usr/include/c++/$(XCVER)\
   -isystem $(SYSROOT)/usr/include/$(XC)/c++/$(XCVER)\
   -isystem $(SYSROOT)/usr/include\
   -isystem $(SYSROOT)/usr/local/include\

  LDFLAGS = --sysroot=$(SYSROOT)\
   -L$(SYSROOT)/usr/lib/gcc/$(XC)/$(XCVER)\
   -L$(SYSROOT)/usr/lib/$(XC)\

 endif
endif

OBJECTS = $(DEVLIB)/ds1302.o $(SERVICE).o
CFLAGS += -I$(DEVLIB) -I. -DNDEBUG

.PHONY: all
all: build build/$(SERVICE)

ifeq ($(XC),)
 GPIO = gpiod
 include $(PROROOT)/wiring/wiring.mk
 include $(PROROOT)/makefiles/arm64.mk
else
 GPIO = gpiod
 include $(PROROOT)/wiring/wiring.mk
 include $(PROROOT)/makefiles/ccpp.mk
endif
include $(PROROOT)/arm/wiringPi/wiringPi.mk
include $(PROROOT)/debug/debug.mk

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
