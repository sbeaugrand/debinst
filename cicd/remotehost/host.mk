# ---------------------------------------------------------------------------- #
## \file host.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# To test with vm, ip = vagrant ssh -c "hostname -I"
URI = vagrant@192.168.121.233
SSH = ssh $(URI)
USERPATH = /home/vagrant
