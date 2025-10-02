# ---------------------------------------------------------------------------- #
## \file avr.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/avr.mk
PROROOT ?= ../..
PROJECT ?= $(shell basename `readlink -f .`)
OBJECTS ?= $(PROJECT).o
ATMEL   ?= attiny2313
EFUSE   ?= 0xff
HFUSE   ?= 0xdf
#PROG   ?= avrisp -b 19200 -P /dev/ttyUSB0# ArduinoISP
PROG    ?= usbtiny

ifneq ($(HARDWARE),)
 TOOLS    = $(HARDWARE)/tools
 PATH    := $(HOME)/bin:$(TOOLS)/avr/bin:$(PATH)
 AVRDUDE  = $(TOOLS)/avrdude -C $(TOOLS)/avrdude.conf -p $(ATMEL) -c $(PROG)
else
 AVRDUDE  = avrdude -p $(ATMEL) -c $(PROG)
endif
CC        = avr-gcc
CXX       = avr-g++
OBJCOPY   = avr-objcopy
CFLAGS   += -g -Os -mmcu=$(ATMEL)
CXXFLAGS += -g -Os -mmcu=$(ATMEL) -fno-exceptions
WARNINGS  = -Wall -Wextra

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

build:
	@mkdir $@

.PHONY: hex
hex: build $(PROJECT).hex checksize

$(PROJECT).hex: build/$(PROJECT).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

build/$(PROJECT).elf: $(OBJECTS)
	$(LINK.o) -o $@ $^ -Wl,--gc-sections -mmcu=$(ATMEL)

$(OBJECTS): Makefile

.PHONY: checksize
checksize: build/$(PROJECT).elf
	@avr-size -C --mcu=$(ATMEL) build/$(PROJECT).elf | sed '/^$$/d'
	@! avr-size -C --mcu=$(ATMEL) build/$(PROJECT).elf | grep '([0-9]\{3\} | grep -v '100.0%''

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
