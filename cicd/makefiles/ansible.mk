# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
-include host.mk

ifeq ($(URI),)
 TARGETS = local
else
 TARGETS = ssh-copy-id | local | remote | mount | umount
 SUDOPASS ?= --extra-vars "ansible_sudo_pass=example"
endif

.PHONY: all
all:
	@echo "Usage: make { $(TARGETS) }"

.PHONY: ssh-copy-id
ssh-copy-id:
	@ssh-copy-id $(URI)

.PHONY: local
local:
	@ansible-playbook $(SUDOPASS) $(LOCAL) playbook.yml

.PHONY: remote
remote:
	@ansible-playbook $(SUDOPASS) playbook.yml

.PHONY: mount
mount:
	@mkdir -p .vagrant
	@test -d /run/lock/.keychain ||\
	 TMPDIR=/run/lock keychain --dir /run/lock --nogui ~/.ssh/id_rsa
	@. /run/lock/.keychain/*-sh &&\
	 sshfs $(URI):$(USERPATH)/ .vagrant

.PHONY: umount
umount:
	@fusermount3 -u .vagrant
