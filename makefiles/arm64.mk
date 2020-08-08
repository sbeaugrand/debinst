# ---------------------------------------------------------------------------- #
## \file arm64.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/arm.mk

ifeq ($(shell uname -m),x86_64)
 CC = aarch64-linux-gnu-gcc
 CXX = aarch64-linux-gnu-g++
endif

include $(PROROOT)/makefiles/ccpp.mk
