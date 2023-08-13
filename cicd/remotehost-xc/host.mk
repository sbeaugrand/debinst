# ---------------------------------------------------------------------------- #
## \file host.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user ?= $(USER)
host ?= pi

IP = $(host)
URI = $(user)@$(IP)
SSH = ssh $(URI)
USERPATH = /home/$(user)

XC = arm-linux-gnueabihf# default: aarch64-linux-gnu
XCVER ?= 10# default: 12
