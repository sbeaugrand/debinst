# ---------------------------------------------------------------------------- #
## \file install-10-WiringPi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/WiringPi/WiringPi.git || return 1
