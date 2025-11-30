# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
SERVICE = ledctl-$(shell grep BOARD= /etc/armbian-image-release | cut -d= -f2)

.SUFFIXES:

.PHONY: all
all:

.PHONY: reinstall
reinstall:

include ../../makefiles/service.mk
