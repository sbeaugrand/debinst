# ---------------------------------------------------------------------------- #
## \file firmware.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BDIR    = $(HOME)/data/install-build
PROJECT = firmware
PROROOT = ../..
PROPATH = avr

ATMEL = attiny45
HFUSE = 0xdd
LFUSE = 0xe1# oscillateur externe, fast rising power

CFLAGS  = -DF_CPU=16500000 -I$(BDIR)/v-usb/usbdrv -I.
CFLAGS += -Wno-implicit-function-declaration
OBJECTS = firmware.o usbdrvasm.o usbFunctionSetup.o\
 $(BDIR)/v-usb/usbdrv/usbdrv.o\
 $(BDIR)/v-usb/libs-device/osccal.o
GPIO = avr
ADC  = avr
include $(PROROOT)/wiring/wiring.mk
include $(PROROOT)/makefiles/avr.mk

build/usbdrvasm.o: $(BDIR)/v-usb/usbdrv/usbdrvasm.S
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@

.PHONY: install
install: /etc/udev/rules.d/99-usbscope.rules

/etc/udev/rules.d/99-usbscope.rules:
	@echo 'SUBSYSTEMS=="usb", DRIVERS=="usb",\
	 ATTR{idProduct}=="0002",\
	 ATTR{idVendor}=="4242",\
	 MODE="0666"' | tr -d '\\' | tr -d '\n' | sudo tee $@ >/dev/null
	@sudo udevadm control --reload-rules
