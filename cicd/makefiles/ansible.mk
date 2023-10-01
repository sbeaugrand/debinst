# ---------------------------------------------------------------------------- #
## \file ansible.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
-include host.mk

ifeq ($(wildcard Vagrantfile),Vagrantfile)
 TARGETS = up | add-ip | del-ip | get-ip
 AARGS = -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
else ifeq ($(URI),)
 TARGETS = local
 AARGS = -e host=all
else
 TARGETS = ssh-copy-id | local | remote | mount | umount | ssh [CMD=\"\"] | halt
 BECOMEPASS ?= --extra-vars "ansible_sudo_pass=example"
endif

define kc
 @test ! -f ~/.ssh/id_rsa || test -d /run/lock/.keychain ||\
  TMPDIR=/run/lock keychain --dir /run/lock --nogui ~/.ssh/id_rsa
 @test ! -f ~/.ssh/id_rsa || . /run/lock/.keychain/*-sh
 $1
endef

define dhcp
 sudo virsh net-update vagrant-libvirt $1 ip-dhcp-host\
  '<host mac="$(MAC)" ip="$(IP)"/>'\
  --live --config --parent-index 0
endef

.SUFFIXES:

.PHONY: all
all:
	@echo "Usage: make { $(TARGETS) }"

.PHONY: add-ip
add-ip:
	@$(call dhcp,add-last)

.PHONY: del-ip
del-ip:
	@$(call dhcp,delete)

.PHONY: get-ip
get-ip:
	@echo $(IP)

.PHONY: up
up:
	@vagrant up --no-provision

.PHONY: ssh-copy-id
ssh-copy-id:
	@ssh-copy-id $(URI)

.PHONY: local
local:
	@ansible-playbook $(BECOMEPASS) $(LOCAL) playbook.yml

.PHONY: remote
remote:
	@user=$(user) ansible-playbook $(BECOMEPASS) playbook.yml

.PHONY: extraroles
extraroles:
	@ansible-playbook ../../makefiles/includeroles.yml $(AARGS)\
	 -e list=$(EXTRAROLES)

.PHONY: sudoers
sudoers:
	@ansible-playbook ../../makefiles/includeroles.yml $(AARGS)\
	 -e list="['sudoers']" --become-method ansible.builtin.su

.PHONY: mount
mount:
	@mkdir .vagrant
	$(call kc,sshfs $(URI):$(USERPATH)/ .vagrant)

.PHONY: umount
umount:
	@fusermount3 -u .vagrant
	@rmdir .vagrant

.PHONY: ssh
ssh:
	@$(call kc,ssh -t $(URI) $(CMD)); true

.PHONY: halt
halt:
	@$(call kc,ssh -t $(URI) "sudo shutdown -P +0"); true
