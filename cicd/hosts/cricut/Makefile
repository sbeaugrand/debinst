# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Setup:
##       vagrant plugin install winrm
##       vagrant plugin install winrm-elevated
##       sudo apt-get install gnome-connections
##       make up
##       make cleanup
##       make usb
##       make bootloader
# ---------------------------------------------------------------------------- #
DOMAIN = windows-10-enterprise-x64-eval_default

.PHONY: all
all:
	@echo "Usage: make up"
	@echo "       make usb"
	@echo "       gnome-connections  # 192.168.121.xxx"
	@echo "       vagrant upload example.svg"
	@echo "       make detach"
	@echo "       make halt"

.PHONY: up
up:
	@vagrant up --no-provision

.PHONY: cleanup
cleanup:
	vagrant upload windows10.bat c:/
	vagrant winrm -e -c c:/windows10.bat

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
