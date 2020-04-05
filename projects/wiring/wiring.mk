# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += wiring/*
CFLAGS += -I$(PROROOT)/wiring
ifeq ($(GPIO),rpi)
 OBJECTS += wiring_digital-rpi.o
 SUDO = sudo
endif
ifeq ($(GPIO),wpi)
 OBJECTS += wiring_digital-wpi.o
 CFLAGS += -DWIRING_PI -I/usr/local/include
 LDFLAGS += -lpthread -lwiringPi
 SUDO = sudo
endif
ifeq ($(GPIO),avr)
 OBJECTS += wiring_digital-avr.o
 include $(PROROOT)/avr/arduino/avr-arduino.mk
endif
ifeq ($(ADC),bcm)
 OBJECTS += wiring_analog-bcm.o
 CFLAGS += -DADC -I/usr/local/include
 LDFLAGS += -lbcm2835 -L/usr/local/lib
 SUDO = sudo
endif
ifeq ($(ADC),wpi)
 OBJECTS += wiring_analog-wpi.o
 CFLAGS += -DWIRING_PI -I/usr/local/include
 LDFLAGS += -lpthread -lwiringPi
 SUDO = sudo
endif
ifeq ($(ADC),g25)
 OBJECTS += wiring_analog-g25.o
 CFLAGS += -DADC
endif
ifeq ($(ADC),avr)
 OBJECTS += wiring_analog-avr.o
endif

build/%.o: $(PROROOT)/wiring/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
