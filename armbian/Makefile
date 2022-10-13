# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= $(USER)
host ?= pi
shutter ?= y

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo -n "Usage: make [user=$(USER)] [host=pi] [shutter=y] "
	@echo -n "{ ssh | rsync | install | volume | "
	@echo "lirc | rtc | oled | oscreensaver | mp3server | shutter }"
	@echo

.PHONY: ssh
ssh:
	@ssh $(user)@$(host); true

.PHONY: rsync
rsync:
	@cd .. && user=$(user) host=$(host) shutter=$(shutter) ./armbian.sh

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

.PHONY: oscreensaver
oscreensaver: install-op-oscreensaver.sh

.PHONY: mp3server
mp3server: install-op-mp3server-bin.sh install-op-mp3server-mnt.sh

.PHONY: shutter
shutter: install-op-shutter.sh

install-op-%.sh: FORCE
	@../0install.sh --root $@

.PHONY: FORCE
FORCE:
