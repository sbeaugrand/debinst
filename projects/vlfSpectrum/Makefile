# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk

CFLAGS += -g $(DEFINES)
ifneq ($(ADC),)
 OBJECTS = adc.o
 ifneq ($(ADC),sinus)
  ifeq ($(shell uname -m),x86_64)
   CC = arm-linux-gnueabihf-gcc
  endif
 endif
endif
ifeq ($(MAKECMDGOALS),fft-usb)
 LDFLAGS += -lusb-1.0
endif

.PHONY: all
all:
	@echo
	@echo "sinus"
	@echo "  make adc ADC=sinus"
	@echo "  make fft-tcp"
	@echo "  build/adc 125 1 50"
	@echo "  build/fft-tcp 0 60 127.0.0.1"
	@echo
	@echo "raspberry Pi"
	@echo "  remote> make adc ADC=[bcm|wpi]"
	@echo "  locale> make fft-tcp"
	@echo "  remote> build/adc [rate]"
	@echo "  locale> build/fft-tcp 0 110 192.168.0.??"
	@echo
	@echo "arietta G25"
	@echo "  remote> make adc ADC=g25"
	@echo "  locale> make fft-tcp"
	@echo "  remote> build/adc [18]"
	@echo "  locale> build/fft-tcp 0 110 192.168.10.10"
	@echo
	@echo "usbscope"
	@echo "  make fft-usb"
	@echo "  build/fft-usb 0 110"
	@echo
	@echo "debug"
	@echo "  make fft-tcp DEFINES=-DPLOT_DEBUG"
	@echo

include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/ccpp.mk
include $(PROROOT)/debug/debug.mk

.PHONY: adc
adc: build build/adc

build/adc: $(OBJECTS)
	$(CC) $^ -lm -lrt $(LDFLAGS) -o $@

.PHONY: fft-tcp
fft-tcp: build build/fft-tcp

.PHONY: fft-usb
fft-usb: build build/fft-usb

build/fft-%: build/fft-%.o build/fft.o build/plot-gnuplot.o
	$(CC) $^ -lm -lfftw3 -lpthread $(LDFLAGS) -o $@

include $(PROROOT)/makefiles/tar.mk
