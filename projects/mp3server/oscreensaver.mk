# ---------------------------------------------------------------------------- #
## \file oscreensaver.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk
SERVICE = oscreensaver

.PHONY: all
all: $(SERVICE)

GPIO = mraa
CXXFLAGS += -I/usr/local/include/upm -I/usr/local/include
include $(PROROOT)/makefiles/arm64.mk
include $(PROROOT)/debug/debug.mk

.PHONY: $(SERVICE)
$(SERVICE): build build/$(SERVICE)
build/$(SERVICE): build/$(SERVICE).o\
 build/oled.o\
 build/lirc.o\
 build/common.o\
 build/setup.o\

	$(CXX) $^ $(LDFLAGS) -lupm-lcd -llirc_client -o $@

build/$(SERVICE).o: $(SERVICE).c

.PHONY: reinstall
reinstall: $(SERVICE)
	@sudo cp build/$(SERVICE) /usr/bin/

include $(PROROOT)/makefiles/service.mk
