# ---------------------------------------------------------------------------- #
## \file avrusb.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || mkdir $repo

gitClone https://github.com/obdev/v-usb.git || return 1
