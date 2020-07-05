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
ifeq ($(GPIO),mraa)
 OBJECTS += wiring_digital-mraa.o
 CFLAGS += -I/usr/local/include
 LDFLAGS += -lmraa
endif
ifeq ($(ADC),bcm)
 OBJECTS += wiring_analog-bcm.o
 CFLAGS += -DRPI -I/usr/local/include
 LDFLAGS += -lbcm2835 -L/usr/local/lib
 SUDO = sudo
endif
ifeq ($(ADC),wpi)
 OBJECTS += wiring_analog-wpi.o
 CFLAGS += -DRPI -DWIRING_PI -I/usr/local/include
 LDFLAGS += -lpthread -lwiringPi
 SUDO = sudo
endif
ifeq ($(ADC),g25)
 OBJECTS += wiring_analog-g25.o
 CFLAGS += -DARIETTA
endif
ifeq ($(ADC),avr)
 OBJECTS += wiring_analog-avr.o
endif
ifeq ($(ADC),sinus)
 OBJECTS += wiring_analog-sinus.o
 CFLAGS += -DSINUS
endif

build/%.o: $(PROROOT)/wiring/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
