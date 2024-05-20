# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
XC = arm-linux-gnueabihf
CPPCHECKINC = --include=build/abstractstubserver.h

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

build/abstractstubserver.h: spec.json
	@cd build && jsonrpcstub ../spec.json --cpp-server=AbstractStubServer

.PHONY: run
run:
	@systemctl -q is-active mpd || sudo systemctl start mpd
	@cd build && make --no-print-directory -j`nproc`
	@build/mpserver /data/mp3
