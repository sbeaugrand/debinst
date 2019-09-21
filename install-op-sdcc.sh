# ---------------------------------------------------------------------------- #
## \file install-op-sdcc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
source install-op-sdcc-src.sh

if notWhich gpasm; then
    pushd $bdir/sdcc/gputils/gputils || return 1
    ./configure >>$log 2>&1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi

if notWhich sdcc; then
    pushd $bdir/sdcc/sdcc/sdcc || return 1
    ./configure >>$log 2>&1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi
