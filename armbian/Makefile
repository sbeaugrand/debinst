# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= $(USER)
host ?= pi

.SUFFIXES:

.PHONY: help
help:
	@echo
	@echo "Usage:"
	@echo "  make ssh [user=<user>] [host=<host>]"
	@echo "  make install"
	@echo "  make (volume | lirc | rtc | oled | mps | shutter | switch)"
	@echo
	@echo "Options:"
	@echo "  user=<user>    [default: $(USER)]."
	@echo "  host=<host>    [default: pi]."
	@echo

.PHONY: ssh
ssh:
	@ssh $(user)@$(host); true

.PHONY: install
install:
	@../0install.sh --root install-[0-9]*.sh

.PHONY: volume
volume: install-op-volume.sh

.PHONY: lirc
lirc: install-op-lirc.sh

.PHONY: rtc
rtc: install-op-rtc.sh

.PHONY: oled
oled: install-op-oled.sh

.PHONY: mps
mps: install-op-mps.sh install-pr-mps.sh

.PHONY: shutter
shutter: install-op-shutter.sh

.PHONY: switch
switch: install-op-switch.sh

install-%.sh: FORCE
	@../0install.sh --root $@

.PHONY: FORCE
FORCE:
