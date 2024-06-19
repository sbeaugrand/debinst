# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note php usage :
##       terminal1> ssh $USER@pi -L 8383:127.0.0.1:8383
##       terminal2> make php
# ---------------------------------------------------------------------------- #
XC = arm-linux-gnueabihf

UN ?= $(USER)
URI = $(UN)@pi
SSH = ssh -t $(URI)
USERPATH = /home/$(UN)

MDIR = /data/mp3

CPPCHECKINC = --include=build/abstractstubserver.h

BROWSER = firefox

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

.PHONY: dir
dir:
	@curl -s -d\
	 '{"jsonrpc":"2.0","method":"dir","params":{"path":"/"},"id":1}'\
	 http://localhost:8383 | python3 -m json.tool

.PHONY: php
php:
	@grep -q "127.0.0.1 $(PROJECT)" /etc/hosts || \
	echo "127.0.0.1 $(PROJECT)" | sudo /usr/bin/tee -a /etc/hosts >/dev/null
	@sudo -b php -S $(PROJECT):8888 -f client.php -t $(shell pwd)
	@sleep 2
	@$(BROWSER) http://$(PROJECT):8888/client.php &
	@echo
	@echo "Type [enter] to quit "
	@echo
	@read ret
	@sudo kill -2 `ps -C "php -S $(PROJECT)" -o pid=`
