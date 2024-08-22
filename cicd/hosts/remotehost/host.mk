# ---------------------------------------------------------------------------- #
## \file host.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# Example to test with vm
-include ../ubuntu2204/host.mk
-include ../hosts/ubuntu2204/host.mk
URI = vagrant@$(IP)
SSH = ssh $(URI)
USERPATH = /vagrant/.vagrant
BHOST = ubuntu2204
SUDOPASS = vagrant
