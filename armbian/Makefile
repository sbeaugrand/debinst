# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= $(USER)
host ?= pi

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo -n "Usage: make [host=pi] { ssh | rsync | install "
	@echo "| lirc | rtc | oled | mp3server }"
	@echo

.PHONY: ssh
ssh:
	@ssh $(user)@$(host); true

.PHONY: rsync
rsync:
	@cd .. && user=$(user) host=$(host) ./armbian.sh

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
