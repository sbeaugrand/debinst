# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
HOST ?= rps

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo -n "Usage: make { ssh | rsync | install "
	@echo "| lirc | rtc | oled | mp3server }"
	@echo

.PHONY: ssh
ssh:
	@ssh $(USER)@$(HOST); true

.PHONY: rsync
rsync:
	@cd .. && user=$(USER) host=$(HOST) ./install-op-rockpi.sh

.PHONY: install
install:
	@../0install.sh

.PHONY: lirc
lirc: install-op-lirc.sh

.PHONY: rtc
rtc: install-op-rtc.sh

.PHONY: oled
oled: install-op-oled.sh install-op-oscreensaver.sh

.PHONY: mp3server
mp3server: install-op-mp3server-bin.sh install-op-mp3server-mnt.sh

install-op-%.sh: FORCE
	@../0install.sh $@

.PHONY: FORCE
FORCE:
