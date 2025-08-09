# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BDIR    = $(HOME)/data/install-build
PROROOT = ../..
PROPATH = avr
include $(PROROOT)/makefiles/pro.mk
OBJECTS = $(PROJECT).o x11Scope.o
FIRMWARE_TARGETS = hex fuse flash verify install

.PHONY: all
all:
	@echo
	@echo -n "Usage: make { $(addsuffix $(empty) $(empty)|,$(FIRMWARE_TARGETS))"
	@echo -n " gui | start "
	@echo $(TARGETS)" }"
	@echo

include $(PROROOT)/makefiles/ccpp.mk
include $(PROROOT)/usb/usb.mk
include $(PROROOT)/x11/x11.mk

.PHONY: $(FIRMWARE_TARGETS)
$(FIRMWARE_TARGETS):
	@$(MAKE) --no-print-directory -f firmware.mk $@

.PHONY: gui
gui: build build/$(PROJECT)

build/$(PROJECT): $(OBJECTS)
	$(CXX) $^ $(LDFLAGS) -o $@

.PHONY: start
start:
	./build/$(PROJECT) /tmp/1

TARDEPEND += makefiles/avr.mk
TARDEPEND += wiring/*
include $(PROROOT)/makefiles/tar.mk
