# ---------------------------------------------------------------------------- #
## \file host.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# Example to test with vm, ip = vagrant ssh -c "hostname -I"
IP = 192.168.121.9
URI = vagrant@$(IP)
SSH = ssh $(URI)
USERPATH = /home/vagrant
BHOST = lubuntu
SUDOPASS = vagrant
