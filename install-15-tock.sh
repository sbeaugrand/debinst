# ---------------------------------------------------------------------------- #
## \file install-15-tock.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd install-*-tock || return 1
sudo -u $user make >>$log 2>&1
popd
