# ---------------------------------------------------------------------------- #
## \file avrusb.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../avrusb
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/obdev/v-usb.git || return 1
