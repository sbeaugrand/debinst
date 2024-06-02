# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
XC = arm-linux-gnueabihf

UN ?= $(USER)
URI = $(UN)@pi
SSH = ssh $(URI)
USERPATH = /home/$(UN)

MDIR = /data/mp3

CPPCHECKINC = --include=build/abstractstubserver.h

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

build/abstractstubserver.h: spec.json
	@cd build && jsonrpcstub ../spec.json --cpp-server=AbstractStubServer

.PHONY: server
server:
	@systemctl -q is-active mpd || sudo systemctl start mpd
	@cd build && make --no-print-directory -j`nproc` mpserver
	@build/mpserver

.PHONY: client
client:
	@cd build && make --no-print-directory -j`nproc` mpclient
	@build/mpclient http://localhost:8383 $(MDIR)
