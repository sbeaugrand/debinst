# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= pi
host ?= rpi

.SUFFIXES:

.PHONY: help
help:
	@echo
	@echo "Usage:"
	@echo "  make (ssh | rsync) [user=<user>] [host=<host>]"
	@echo "  make install"
	@echo
	@echo "Options:"
	@echo "  user=<user>  User name [default: pi]."
	@echo "  host=<host>  Host name [default: rpi]."
	@echo

.PHONY: ssh
ssh:
	@ssh $(user)@$(host); true

.PHONY: rsync
rsync:
	@cd .. && user=$(user) host=$(host) raspbian/raspbian.sh

.PHONY: install
install:
	@../0install.sh --root install-[0-9]*.sh
