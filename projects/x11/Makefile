# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ..
include ${PROROOT}/makefiles/pro.mk

LIB = libx11pp.a
CXXFLAGS = -DNDEBUG

all: build $(LIB)

include $(PROROOT)/makefiles/ccpp.mk

$(LIB): $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^

include $(PROROOT)/makefiles/tar.mk
