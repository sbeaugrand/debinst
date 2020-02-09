# ---------------------------------------------------------------------------- #
## \file avr.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/avr.mk
ifeq ($(PROROOT),)
 PROROOT = ../..
endif
ifeq ($(PROJECT),)
 PROJECT = $(shell basename `readlink -f .`)
endif
ifeq ($(OBJECTS),)
 OBJECTS = $(PROJECT).o
endif
ifeq ($(ATMEL),)
 ATMEL = attiny2313
endif
ifeq ($(EFUSE),)
 EFUSE = 0xff
endif
ifeq ($(HFUSE),)
 HFUSE = 0xdf
endif
ifeq ($(PROG),)
 PROG = usbtiny
endif

ifneq ($(HARDWARE),)
 TOOLS    = $(HARDWARE)/tools
 PATH    := $(TOOLS)/avr/bin:$(PATH)
 AVRDUDE  = $(TOOLS)/avrdude -C $(TOOLS)/avrdude.conf -p $(ATMEL) -c $(PROG)
else
 AVRDUDE  = avrdude -p $(ATMEL) -c $(PROG)
endif
ifeq ($(MAKECMDGOALS),hex)
 CC        = avr-gcc
 CXX       = avr-g++
 OBJCOPY   = avr-objcopy
 CFLAGS   += -Os -mmcu=$(ATMEL)
 CXXFLAGS += -Os -mmcu=$(ATMEL) -fno-exceptions
endif

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "PROJECT="$(PROJECT)
	@echo "AVRDUDE="$(AVRDUDE)
	@echo "HFUSE="$(HFUSE)
	@echo "LFUSE="$(LFUSE)
	@echo
	@echo -n "Usage: make { hex | fuse | flash | verify "
	@echo $(TARGETS)" }"
	@echo

include $(PROROOT)/makefiles/ccpp.mk

.PHONY: hex
hex: build $(PROJECT).hex

$(PROJECT).hex: build/$(PROJECT).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

build/$(PROJECT).elf: $(OBJECTS)
	$(LINK.o) -o $@ $^ -Wl,--gc-sections -mmcu=$(ATMEL)

.PHONY: fuse
fuse:
	$(AVRDUDE) -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

.PHONY: flash
flash: $(PROJECT).hex
	$(AVRDUDE) -U flash:w:$<

.PHONY: verify
verify:
	$(AVRDUDE) -U flash:v:$(PROJECT).hex && \
	$(AVRDUDE) -U efuse:v:$(EFUSE):m -U hfuse:v:$(HFUSE):m -U lfuse:v:$(LFUSE):m
