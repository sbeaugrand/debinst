# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note
##  Terminal example
##   make C=term
##   make C=term vserver
##   make C=term vclient
##
##  Rock Pi S example
##   make C=rps
##   make C=rps install
##   make C=rps start
##
##  Raspberry Pi example
##   make C=rpi
##   make C=rpi install
##   make C=rpi start
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk
ifeq ($(C),)
 $(error "Usage: make C=<term|rps|rpi>")
endif

SERVER = mp3server
CLIENT = mp3client
CFLAGS = -g -DNDEBUG
CXXFLAGS = -g -DNDEBUG

.PHONY: all
all: server client

ifeq ($(C),term)
 include $(PROROOT)/makefiles/ccpp.mk
endif
ifeq ($(C),rps)
 GPIO = mraa
 DEVOBJ = build/mp3client-oled.o build/mp3client-lirc.o
 CXXFLAGS += -I/usr/local/include/upm -I/usr/local/include
 DEVFLAGS = -lupm-lcd -lstdc++ -llirc_client
 include $(PROROOT)/makefiles/arm64.mk
endif
ifeq ($(C),rpi)
 DEVOBJ = build/mp3client-lcd16x2.o build/mp3client-button.o
 DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
 CFLAGS += -I$(DEVLIB) -DRPI -I/usr/local/include
 OBJECTS = $(DEVLIB)/lcd.o
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
build/$(CLIENT): build/$(CLIENT).o build/common.o $(DEVOBJ)
ifeq ($(C),term)
	$(CC) $^ $(LDFLAGS) -o $@
else
	$(CC) $^ $(LDFLAGS) $(DEVFLAGS) -o $@
endif
build/$(CLIENT)-oled.o: $(CLIENT)-oled.cpp

.PHONY: oled-clear
oled-clear: build build/oled-clear
build/oled-clear: build/oled-clear.o
	$(CXX) $^ $(LDFLAGS) -lupm-lcd -o $@
build/oled-clear.o: oled-clear.cpp

.PHONY: test-buffer
test-buffer: build build/test-buffer
build/test-buffer: build/test-buffer.o build/common.o
	$(CC) $^ -o $@

.PHONY: test-rand
test-rand: build build/test-rand
build/test-rand: build/test-rand.o
	$(CC) $^ -o $@

SERVICE=$(SERVER)
include $(PROROOT)/makefiles/service.mk
include $(PROROOT)/makefiles/tar.mk
