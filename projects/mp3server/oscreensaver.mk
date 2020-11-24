# ---------------------------------------------------------------------------- #
## \file oscreensaver.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk
SERVICE = oscreensaver

GPIO = mraa
CXXFLAGS += -I/usr/local/include/upm -I/usr/local/include
DEVFLAGS = -lupm-lcd -lstdc++
include $(PROROOT)/makefiles/arm64.mk
include $(PROROOT)/debug/debug.mk

.PHONY: $(SERVICE)
$(SERVICE): build build/$(SERVICE)
build/$(SERVICE): build/$(SERVICE).o build/mp3client-oled.o build/common.o
	$(CXX) $^ $(LDFLAGS) -lupm-lcd -o $@
build/$(SERVICE).o: $(SERVICE).c

.PHONY: reinstall
reinstall: $(SERVICE)
	@sudo cp build/$(SERVICE) /usr/bin/

include $(PROROOT)/makefiles/service.mk
