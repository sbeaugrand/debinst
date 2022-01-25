# ---------------------------------------------------------------------------- #
## \file install-op-marlin-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
gitClone https://github.com/MarlinFirmware/Marlin.git || return 1
