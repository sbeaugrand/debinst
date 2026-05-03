# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
EXTRAROLES ?= dell7510
include ../../makefiles/ansible.mk

.PHONY: hotspot
hotspot:
	@make --no-print-directory extraroles EXTRAROLES=hotspot EXTRAVARS="-e ip=10.66.0.2 -e iface=wlp2s0 -e gateway=192.168.0.254"
