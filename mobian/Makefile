# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
debianIpaddr = 10.66.0.2
contacts = .local/share/evolution/addressbook/system/contacts.db

define ipforward
 test -d /run/lock/.keychain || echo "\nwarn: /run/lock/.keychain not found\n"
 ip address | grep -q $(debianIpaddr) || ./ipforward.sh
endef

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "Usage: make { rsync | install | ssh | xssh | contacts | dns | upgrade }"
	@echo

.PHONY: rsync
rsync:
	@$(call ipforward)
	@cd .. && mobian/mobian.sh

.PHONY: install
install:
	@../0install.sh --root install-[0-9]*.sh

.PHONY: ssh
ssh:
	@$(call ipforward)
	@ssh mobian@mobian; true

.PHONY: xssh
xssh:
	@$(call ipforward)
	@ssh mobian@mobian -Y; true

.PHONY: contacts
contacts:
	@$(call ipforward)
	@scp $(HOME)/$(contacts) mobian@mobian:/home/mobian/$(contacts)

.PHONY: dns
dns:
	@../0install.sh --root install-*-dns.sh

.PHONY: upgrade
upgrade:
	@sudo apt-get -y update
	@sudo apt-get -y dist-upgrade
