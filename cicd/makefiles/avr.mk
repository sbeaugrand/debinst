# ---------------------------------------------------------------------------- #
## \file avr.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example 1
##
##       ATMEL = attiny45
##       FLAGS = -DF_CPU=8000000UL
##       PROG ?= avrisp -b 19200 -P /dev/ttyUSB0# ArduinoISP
##
##       ARDUINO = ATTinyCore
##       CORE    = $(ARDUINO)/avr/cores/tiny
##       PINS    = $(ARDUINO)/avr/variants/tinyx5
##       FLAGS  += -I$(CORE) -I$(PINS)
##
##       OBJECTS += $(PROJECT).o
##       OBJECTS += core_main.o
##       include avr.mk
##
## \note Example 2
##
##       ATMEL = atmega328p
##       FLAGS = -DF_CPU=16000000L
##       PROG ?= arduino -P/dev/ttyACM0
##
##       ARDUINO = /usr/share/arduino/hardware/arduino
##       CORE    = $(ARDUINO)/avr/cores/arduino
##       PINS    = $(ARDUINO)/avr/variants/standard
##       FLAGS  += -I$(CORE) -I$(PINS)
##
##       OBJECTS += $(PROJECT).o
##       OBJECTS += core_wiring.o
##       OBJECTS += core_wiring_digital.o
##       include avr.mk
##
# ---------------------------------------------------------------------------- #
PROJECT ?= $(shell basename `readlink -f .`)
OBJECTS ?= $(PROJECT).o
ATMEL   ?= attiny2313
EFUSE   ?= 0xff
HFUSE   ?= 0xdf
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
FLAGS    += -g -Os -mmcu=$(ATMEL)
FLAGS    += -ffunction-sections
FLAGS    += -fdata-sections
CFLAGS   += $(FLAGS)
CXXFLAGS += $(FLAGS) -fno-exceptions
WARNINGS  = -Wall -Wextra
OBJECTS  := $(addprefix build/,$(OBJECTS))

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

build/core_%.o: $(CORE)/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

build/core_%.o: $(CORE)/%.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

build/%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

build/%.o: %.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(OBJECTS): Makefile

.PHONY: checksize
checksize: build/$(PROJECT).elf
	@  avr-size --format=avr --mcu=$(ATMEL) build/$(PROJECT).elf | sed '/^$$/d'
	@! avr-size --format=avr --mcu=$(ATMEL) build/$(PROJECT).elf | grep '([0-9]\{3\} | grep -v '100.0%''

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

.PHONY: cppcheck
cppcheck:
	@eval cppcheck -q --enable=all\
	 `test -f cppcheck.supp && echo --suppressions-list=cppcheck.supp`\
	 --template='{id}:{file}:{line}\ \({severity}\)\ {message}'\
	 --inline-suppr\
	 -i build -i build-*\
	 --suppress=missingIncludeSystem --suppress=checkersReport\
	 --check-level=exhaustive\
	 $(CPPCHECKINC) .
