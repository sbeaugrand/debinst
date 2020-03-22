# ---------------------------------------------------------------------------- #
## \file x11.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += x11
OBJECTS += ${PROROOT}/x11/libx11pp.a
CXXFLAGS += -I$(PROROOT)
LDFLAGS += -lX11

$(PROROOT)/x11/libx11pp.a:
	@cd $(PROROOT)/x11 && make --no-print-directory
