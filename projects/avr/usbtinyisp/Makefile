# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny2313&LOW=EF
# ---------------------------------------------------------------------------- #
BDIR    = $(HOME)/data/install-build
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk
PROPATH = avr

LFUSE = 0xef# quartz >= 8 MHz
PROG  = dapa
include $(PROROOT)/makefiles/avr.mk

.PHONY: install
install: main.hex /etc/udev/rules.d/99-usbtinyisp.rules

main.hex: $(BDIR)/usbtinyisp/spi/main.hex
	@cp $< $@

/etc/udev/rules.d/99-usbtinyisp.rules:
	@echo 'SUBSYSTEMS=="usb", DRIVERS=="usb",\
	 ATTR{idProduct}=="0c9f",\
	 ATTR{idVendor}=="1781",\
	 ATTR{product}=="USBtiny",\
	 MODE="0666"' | tr -d '\\' | tr -d '\n' | sudo tee $@ >/dev/null
	@sudo udevadm control --reload-rules

include $(PROROOT)/makefiles/tar.mk
