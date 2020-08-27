# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk

T ?= hex

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "Emetteur lifi arduino"
	@echo "  make emi"
	@echo "  make emi T=flash"
	@echo
	@echo "Recepteur lifi arduino"
	@echo "  make rec"
	@echo "  make rec T=flash"
	@echo
	@echo "Emetteur lifi attiny45"
	@echo "  make avr"
	@echo "  make avr T=fuse"
	@echo "  make avr T=flash"
	@echo
	@echo "Recepteur lifi RockpiS libmraa"
	@echo "  make arm GPIO=mraa"
	@echo

.PHONY: emi
emi:
	@$(MAKE) --no-print-directory -f Makefile.arduino $(T) PROJECT=LiFiEmitter

.PHONY: rec
rec:
	@$(MAKE) --no-print-directory -f Makefile.arduino $(T) PROJECT=LiFiReceiver

.PHONY: avr
avr:
	@$(MAKE) --no-print-directory -f Makefile.avr $(T)

.PHONY: arm
arm:
	@$(MAKE) --no-print-directory -f Makefile.arm GPIO=$(GPIO)

.PHONY: debug
debug:
	@sudo ./build/receiver-mraa

.PHONY: test
test:
	@sudo build/receiver-mraa 2 | tr -d '\n' && echo

.PHONY: reinstall
reinstall: $(PROJECT)
	@sudo cp $(PROJECT) /usr/bin/

include $(PROROOT)/makefiles/daemon.mk

.PHONY: clean
clean:
	@$(RM) build/*.o build/*.d build/*.elf *~

TARDEPEND += makefiles/*
TARDEPEND += wiring/*
TARDEPEND += debug/*
TARDEPEND += avr/arduino/*
TARDEPEND += avr/timer/*
include $(PROROOT)/makefiles/tar.mk
