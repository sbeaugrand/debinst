# ---------------------------------------------------------------------------- #
## \file install-06-ledctl.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd ledctl || return 1
make install
make start
popd
