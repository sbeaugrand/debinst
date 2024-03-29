# ---------------------------------------------------------------------------- #
## \file host.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# Example to test with vm
-include ../lubuntu/host.mk
-include ../hosts/lubuntu/host.mk
URI = vagrant@$(IP)
SSH = ssh $(URI)
USERPATH = /vagrant/.vagrant
BHOST = lubuntu
SUDOPASS = vagrant
