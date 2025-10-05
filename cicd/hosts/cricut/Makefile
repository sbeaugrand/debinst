# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note vagrant plugin install winrm
##       vagrant plugin install winrm-elevated
##       sudo apt install gnome-connections
# ---------------------------------------------------------------------------- #
DOMAIN = windows-10-enterprise-x64-eval_default

.PHONY: all
all:
	@echo "Usage: make { up | usb | bootloader | detach | halt }"

.PHONY: up
up:
	@vagrant up --no-provision

.PHONY: usb
usb:
	@sudo virsh attach-device $(DOMAIN) usb-device.xml --current

.PHONY: bootloader
bootloader:
	@sudo virsh attach-device $(DOMAIN) bootloader.xml --current

.PHONY: detach
detach:
	@sudo virsh detach-device $(DOMAIN) usb-device.xml

.PHONY: halt
halt:
	@vagrant halt
