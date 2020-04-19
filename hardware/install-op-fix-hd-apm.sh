# ---------------------------------------------------------------------------- #
## \file install-op-fix-hd-apm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
/sbin/hdparm -B254 /dev/sda
