# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
XC ?= arm-linux-gnueabihf
BUILD ?= Release
CMAKE = cmake libjson-rpc-cpp -DCMAKE_BUILD_TYPE=$(BUILD)

UN ?= $(USER)
URI = $(UN)@pi
SSH = ssh -t $(URI)

.PHONY: all
all:
	@echo "Usage: make build"
	@echo "       make package"
	@echo "       make xbuild"
	@echo "       make xpackage"
	@echo "       make rpackage"
	@echo "       make rxpackage"

include ../makefiles/gitlabci.mk
