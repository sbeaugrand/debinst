# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BHOST = debian12
HOST = armbian
XC ?= arm-linux-gnueabihf

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

# ---------------------------------------------------------------------------- #
# build
# ---------------------------------------------------------------------------- #
.PHONY: stub
stub: abstractstubserver.h
abstractstubserver.h: spec.json
	@jsonrpcstub $< --cpp-server=AbstractStubServer

.PHONY: release
release:
	@echo
	@$(call print-help,Create chroot)
	@echo
	@$(call print-help,Release)
	@echo

# ---------------------------------------------------------------------------- #
# interface
# ---------------------------------------------------------------------------- #
BROWSER = firefox

.PHONY: tunnel
tunnel:
	@ssh $(URI) -L 8383:127.0.0.1:8383

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

# ---------------------------------------------------------------------------- #
# tests
# ---------------------------------------------------------------------------- #
.PHONY: server
server:
	@systemctl -q is-active mpd || sudo systemctl start mpd
	@cd build && make --no-print-directory -j`nproc` mpserver
	@build/mpserver

.PHONY: client
client:
	@cd build && make --no-print-directory -j`nproc` mpclient
	@build/mpclient http://localhost:8383

.PHONY: dir
dir:
	@curl -s -d\
	 '{"jsonrpc":"2.0","method":"dir","params":{"path":"$(path)"},"id":1}'\
	 http://localhost:8383 | python3 -m json.tool

# ---------------------------------------------------------------------------- #
# doc
# ---------------------------------------------------------------------------- #
.PHONY: mermaid
mermaid: README-0.md
README-0.md: README.md
	${call mermaid,$<,$@}

.PHONY: resize
resize: README-0-1.svg README-0-2.svg
README-0-1.svg README-0-2.svg: FORCE
	$(call resize,$@)
