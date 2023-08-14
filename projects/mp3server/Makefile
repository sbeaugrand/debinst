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
##  Pi example
##   make C=pi
##   make C=pi install
##   make C=pi start
##
##  Raspberry Pi example
##   make C=rpi
##   make C=rpi install
##   make C=rpi start
##
##  Cross compile for arm with sysroot
##   See ../../cicd/remotehost-xc/README.md
##   make C=pi XC=aarch64-linux-gnu
##   make C=pi XC=aarch64-linux-gnu oled-message
##   make C=pi XC=arm-linux-gnueabihf XCVER=10
##   make C=pi XC=arm-linux-gnueabihf XCVER=10 oled-message
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk
ifeq ($(C),)
 $(error "Usage: make C=<term|pi|rpi>")
endif
user ?= $(USER)

SERVER = mp3server
CLIENT = mp3client

ifneq ($(XC),)
 XCVER ?= 12
 XCDIR ?= /data
 SYSROOT = $(XCDIR)/$(XC)-$(XCVER)
 CC = $(XC)-gcc
 CXX = $(XC)-g++
 CFLAGS = --sysroot=$(SYSROOT) -nostdinc\
  -I${SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include\
  -I$(SYSROOT)/usr/include/$(XC)\

 CXXFLAGS = --sysroot=$(SYSROOT) -nostdinc\
  -I${SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include\
  -I$(SYSROOT)/usr/include/$(XC)\

 CFLAGS +=\
  -isystem $(SYSROOT)/usr/include\
  -isystem $(SYSROOT)/usr/local/include\

 CXXFLAGS +=\
  -isystem $(SYSROOT)/usr/include/c++/$(XCVER)\
  -isystem $(SYSROOT)/usr/include/$(XC)/c++/$(XCVER)\
  -isystem $(SYSROOT)/usr/include\
  -isystem $(SYSROOT)/usr/local/include\

 LDFLAGS = --sysroot=$(SYSROOT)\
  -L$(SYSROOT)/usr/lib/gcc/$(XC)/$(XCVER)\
  -L$(SYSROOT)/usr/lib/$(XC)\

endif

#PLAYER = xmms
#CFLAGS += -I$(SYSROOT)/usr/include/xmms2
PLAYER = mpd
CFLAGS += -DMPD
SERVERFLAGS = -l$(PLAYER)client

CXXFLAGS +=\
 -I$(SYSROOT)/usr/local/include/upm\

CFLAGS += -Wfatal-errors -g -DNDEBUG
CXXFLAGS += -Wfatal-errors -g -DNDEBUG

.PHONY: all
all: server client

ifeq ($(C),term)
 DEVOBJ = build/$(CLIENT)-term.o
 include $(PROROOT)/makefiles/ccpp.mk
endif
ifeq ($(C),pi)
 GPIO = mraa
 DEVOBJ = build/oled.o build/lirc.o
 CLIENTFLAGS = -lupm-lcd -lstdc++ -llirc_client
 ifeq ($(SYSROOT),)
  include $(PROROOT)/makefiles/arm64.mk
 else
  include $(PROROOT)/makefiles/ccpp.mk
 endif
endif
ifeq ($(C),rpi)
 DEVOBJ = build/$(CLIENT)-lcd16x2.o build/$(CLIENT)-button.o
 DEVLIB = $(HOME)/data/install-build/WiringPi/devLib
 CFLAGS += -I$(DEVLIB) -DRPI -I/usr/local/include
 OBJECTS = $(DEVLIB)/lcd.o
 CLIENTFLAGS = -lwiringPi -lwiringPiDev -lpthread
 include $(PROROOT)/makefiles/arm.mk
endif
include $(PROROOT)/debug/debug.mk

.PHONY: reinstall
reinstall: server client /etc/init.d/$(SERVER)d
	@sudo cp build/$(SERVER) build/$(CLIENT) /usr/bin/
/etc/init.d/$(SERVER)d: $(SERVER)d
	@sed "s/user=.*/user=$(user)/" $< | sudo tee $@ >/dev/null
	@sudo chmod 755 $@

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
	$(CC) $^ $(LDFLAGS) $(SERVERFLAGS) -o $@
build/player.o: player-$(PLAYER).c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: client
client: build build/$(CLIENT)
build/$(CLIENT): build/$(CLIENT).o build/common.o build/setup.o $(DEVOBJ)
	$(CC) $^ $(LDFLAGS) $(CLIENTFLAGS) -o $@

.PHONY: oled-message
oled-message: build build/oled-message
build/oled-message: build/oled-message.o
	$(CXX) $^ $(LDFLAGS) -lupm-lcd -lmraa -o $@
.PHONY: install-oled-message
install-oled-message: /usr/bin/oled-message
/usr/bin/oled-message: build/oled-message
	@sudo cp $< $@

.PHONY: test-buffer
test-buffer: build build/test-buffer
build/test-buffer: build/test-buffer.o build/common.o
	$(CC) $^ -o $@

.PHONY: test-rand
test-rand: build build/test-rand
build/test-rand: build/test-rand.o
	$(CC) $^ -o $@

SERVICE = $(SERVER)
include $(PROROOT)/makefiles/service.mk
include $(PROROOT)/makefiles/tar.mk
