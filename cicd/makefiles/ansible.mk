# ---------------------------------------------------------------------------- #
## \file ansible.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
-include host.mk

ifeq ($(URI),)
 TARGETS = local
else
 TARGETS = ssh-copy-id | local | remote | mount | umount
 BECOMEPASS ?= --extra-vars "ansible_sudo_pass=example"
endif

define kc
 test ! -f ~/.ssh/id_rsa || test -d /run/lock/.keychain ||\
  TMPDIR=/run/lock keychain --dir /run/lock --nogui ~/.ssh/id_rsa
 test ! -f ~/.ssh/id_rsa || . /run/lock/.keychain/*-sh
 $1
endef

.PHONY: all
all:
	@echo "Usage: make { $(TARGETS) }"

.PHONY: ssh-copy-id
ssh-copy-id:
	@ssh-copy-id $(URI)

.PHONY: local
local:
	@ansible-playbook $(BECOMEPASS) $(LOCAL) playbook.yml

.PHONY: remote
remote:
	@ansible-playbook $(BECOMEPASS) playbook.yml

.PHONY: mount
mount:
	@mkdir -p .vagrant
	@$(call kc,sshfs $(URI):$(USERPATH)/ .vagrant)

.PHONY: umount
umount:
	@fusermount3 -u .vagrant
