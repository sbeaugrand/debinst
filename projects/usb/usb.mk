# ---------------------------------------------------------------------------- #
## \file usb.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += usb
OBJECTS += ${PROROOT}/usb/libusbpp.a
CXXFLAGS += -I$(PROROOT)
LDFLAGS += -lusb-1.0

$(PROROOT)/usb/libusbpp.a:
	@cd $(PROROOT)/usb && make --no-print-directory
