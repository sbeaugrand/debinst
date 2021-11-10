# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= pi
host ?= rpi

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "Usage: make [user=pi] [host=rpi] { ssh | rsync | install }"
	@echo

.PHONY: ssh
ssh:
	@ssh $(user)@$(host); true

.PHONY: rsync
rsync:
	@cd .. && user=$(user) host=$(host) ./rpi.sh

.PHONY: install
install:
	@../0install.sh
