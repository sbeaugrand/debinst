# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
XC = arm-linux-gnueabihf

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

.PHONY: run
run:
	@cd build && make --no-print-directory -j`nproc`
	@build/mpclient /data/mp3 http://localhost:8383
