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
##  Raspberry PI example
##   make C=rpi
##   make C=rpi install
##   make start
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk

SERVER = mp3server
CLIENT = mp3client
CFLAGS = -g -DNDEBUG
ifeq ($C,rpi)
 ifeq ($(shell uname -m),x86_64)
  CC = arm-linux-gnueabihf-gcc
 endif
 CFLAGS += -DRPI -I/usr/local/include
 RPIFLAGS = -lwiringPi -lwiringPiDev -lpthread
endif

.PHONY: all
all: server client

include $(PROROOT)/makefiles/ccpp.mk
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

build/$(CLIENT): build/$(CLIENT).o build/$(CLIENT)-$(C).o build/common.o
ifeq ($(C),rpi)
	$(CC) $^ $(LDFLAGS) $(RPIFLAGS) -o $@
else
	$(CC) $^ $(LDFLAGS) -o $@
endif

build/$(CLIENT)-.o:
	@echo
	@echo "Usage: make C=<term|rpi>"
	@echo
	@false

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
