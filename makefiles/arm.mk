# ---------------------------------------------------------------------------- #
## \file arm.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/arm.mk

ifeq ($(shell uname -m),x86_64)
 CC = arm-linux-gnueabihf-gcc
endif

include $(PROROOT)/makefiles/ccpp.mk
