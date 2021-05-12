# ---------------------------------------------------------------------------- #
## \file install-op-cppcheck.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

gitClone https://github.com/danmar/cppcheck.git || return 1

if notWhich cppcheck; then
    pushd $bdir/cppcheck
    make >>$log 2>&1 FILESDIR=/usr/share/cppcheck
    make >>$log 2>&1 FILESDIR=/usr/share/cppcheck install
    popd
fi
