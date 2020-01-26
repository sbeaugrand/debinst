# ---------------------------------------------------------------------------- #
## \file install-op-rpi-xc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
MAKE_OPT="ARFLAGS=cr"\
 host_alias=arm-linux-gnueabihf\
 source install-op-rpi/install-11-bcm.sh
