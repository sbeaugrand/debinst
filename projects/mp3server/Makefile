# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note
##  Terminal example
##   make C=term
##   make vserver
##   make vclient
##
##  Rock Pi S example
##   make C=rps
##   make C=rps install
##   make start
##
##  Raspberry Pi example
##   make C=rpi
##   make C=rpi install
##   make start
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk
ifeq ($(C),)
 $(error "Usage: make C=<term|rpi|rps>")
endif

SERVER = mp3server
CLIENT = mp3client
CFLAGS = -g -DNDEBUG

.PHONY: all
all: server client

ifeq ($(C),term)
 include $(PROROOT)/makefiles/ccpp.mk
endif
ifeq ($(C),rps)
 GPIO = mraa
 DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
 CFLAGS += -I$(DEVLIB) -DROCKPIS
 OBJECTS = $(DEVLIB)/lcd.o
 include $(PROROOT)/wiring/wiring.mk
 include $(PROROOT)/makefiles/arm.mk
 include $(PROROOT)/arm/wiringPi/wiringPi.mk
 DEVOBJ = $(OBJECTS)
endif
ifeq ($(C),rpi)
 CFLAGS += -DRPI -I/usr/local/include
 DEVFLAGS = -lwiringPi -lwiringPiDev -lpthread
 include $(PROROOT)/makefiles/arm.mk
endif
include $(PROROOT)/debug/debug.mk

.PHONY: reinstall
reinstall: server client
	@sudo cp build/$(SERVER) build/$(CLIENT) /usr/bin/

.PHONY: vserver
vserver:
	@valgrind --leak-check=full --show-leak-kinds=all -q build/$(SERVER)

.PHONY: vclient
vclient:
	@valgrind --leak-check=full --show-leak-kinds=all -q build/$(CLIENT)

.PHONY: server
server: build build/$(SERVER)

build/$(SERVER): build/$(SERVER).o build/player.o build/httpServer.o \
	build/resources.o build/log.o build/html.o build/common.o
	$(CC) $^ -lxmmsclient -o $@

build/player.o: player.c
	$(CC) $(CFLAGS) -I/usr/include/xmms2 -c $< -o $@

.PHONY: client
client: build build/$(CLIENT)

build/$(CLIENT): \
	build/$(CLIENT).o build/$(CLIENT)-$(C).o build/common.o $(DEVOBJ)
ifeq ($(C),term)
	$(CC) $^ $(LDFLAGS) -o $@
else
	$(CC) $^ $(LDFLAGS) $(DEVFLAGS) -o $@
endif

.PHONY: test-buffer
test-buffer: build build/test-buffer
build/test-buffer: build/test-buffer.o build/common.o
	$(CC) $^ -o $@

.PHONY: test-rand
test-rand: build build/test-rand
build/test-rand: build/test-rand.o
	$(CC) $^ -o $@

include $(PROROOT)/makefiles/daemon.mk
include $(PROROOT)/makefiles/tar.mk
