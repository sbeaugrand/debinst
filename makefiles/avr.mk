# ---------------------------------------------------------------------------- #
## \file avr.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/avr.mk
ifeq "$(PROROOT)" ""
 PROROOT = ../..
endif
ifeq "$(PROJECT)" ""
 PROJECT = $(shell basename `readlink -f .`)
endif
ifeq "$(OBJECTS)" ""
 OBJECTS = build/main.o
else
 OBJECTS := $(subst build//,/,$(addprefix build/,$(OBJECTS)))
endif
ifeq "$(ATTINY)" ""
 ATTINY = 2313
endif
ifeq "$(EFUSE)" ""
 EFUSE = 0xff
endif
ifeq "$(HFUSE)" ""
 HFUSE = 0xdf
endif
ifeq "$(PROG)" ""
 PROG = usbtiny
endif

ifneq ($(AVRROOT),)
 HARDWARE = $(AVRROOT)/tmp/arduino-1.0.6/hardware
 TOOLS    = $(HARDWARE)/tools
 PATH    := $(TOOLS)/avr/bin:$(PATH)
 AVRDUDE  = $(TOOLS)/avrdude -C $(TOOLS)/avrdude.conf -p t$(ATTINY) -c $(PROG)
else
 AVRDUDE  = avrdude -p t$(ATTINY) -c $(PROG)
endif
ifeq "$(MAKECMDGOALS)" "hex"
 CC       = avr-gcc
 OBJCOPY  = avr-objcopy
 CFLAGS  += -Os -mmcu=attiny$(ATTINY)
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
	@echo -n "Usage: make { hex | fuse | flash | verify"
	@echo $(TARGETS)" | clean | mrproper }"
	@echo

include $(PROROOT)/makefiles/ccpp.mk

.PHONY: hex
hex: build main.hex

main.hex: build/main.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

build/main.elf: $(OBJECTS)
	$(LINK.o) -o $@ $^ -Wl,--gc-sections -mmcu=attiny$(ATTINY)

%.s: %.c
	$(CC) $(CFLAGS) -S -o $@ $<

.PHONY: fuse
fuse:
	$(AVRDUDE) -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

.PHONY: flash
flash:
	$(AVRDUDE) -U flash:w:main.hex

.PHONY: verify
verify:
	$(AVRDUDE) -U flash:v:main.hex && \
	$(AVRDUDE) -U efuse:v:$(EFUSE):m -U hfuse:v:$(HFUSE):m -U lfuse:v:$(LFUSE):m
