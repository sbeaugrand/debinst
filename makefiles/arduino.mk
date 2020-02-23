# ---------------------------------------------------------------------------- #
## \file arduino.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note arduino 1.0.6 Uno
##       g++: -Os -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -DUSB_VID=null -DUSB_PID=null -DARDUINO=106
##       gcc: -Os                 -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -DUSB_VID=null -DUSB_PID=null -DARDUINO=106
##       lnk: -Os -Wl,--gc-sections -mmcu=atmega328p
##       avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 <elf> <eep>
##       avr-objcopy -O ihex -R .eeprom <elf> <hex>
## \note arduino 1.8.10 Uno
##       g++: -Os -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10810 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR
##       gcc: -Os -std=gnu11                                -ffunction-sections -fdata-sections -flto -fno-fat-lto-objects                         -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10810 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR
##       lnk: -Os -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p
##       avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 <elf> <eep>
##       avr-objcopy -O ihex -R .eeprom <elf> <hex>
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/arduino.mk
ifeq ($(HARDWARE),)
 $(error HARDWARE is not set)
endif
ifeq ($(ARDUINO),)
 $(error ARDUINO is not set)
endif

ATMEL = atmega328p
PROG  = arduino -D -P/dev/ttyACM0 -b115200
FLAGS =\
 -ffunction-sections\
 -fdata-sections\
 -DF_CPU=16000000L\
 -DUSB_VID=null\
 -DUSB_PID=null\
 -DARDUINO=106\
 -I$(ARDUINO)/variants/standard\
 -I$(ARDUINO)/cores/arduino
CFLAGS   += $(FLAGS)
CXXFLAGS += $(FLAGS)
OBJECTS  += $(ARDUINO)/cores/arduino/main.o
include $(PROROOT)/makefiles/avr.mk
