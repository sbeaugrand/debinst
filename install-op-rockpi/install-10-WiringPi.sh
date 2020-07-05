# ---------------------------------------------------------------------------- #
## \file install-op-WiringPi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../WiringPi
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone git://github.com/WiringPi/WiringPi.git || return 1
