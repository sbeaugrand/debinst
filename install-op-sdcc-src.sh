# ---------------------------------------------------------------------------- #
## \file install-op-sdcc-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

if notFile $repo/sdcc.tgz; then
    if notDir $bdir/sdcc; then
        mkdir $bdir/sdcc
    fi
    if notDir $bdir/sdcc/gputils; then
        pushd $bdir/sdcc || return 1
        svn checkout svn://svn.code.sf.net/p/gputils/code/trunk gputils >>$log
        popd
    else
        return 1
    fi
    if notDir $bdir/sdcc/sdcc; then
        pushd $bdir/sdcc || return 1
        svn checkout svn://svn.code.sf.net/p/sdcc/code/trunk sdcc >>$log
        popd
    else
        return 1
    fi
    pushd $bdir || return 1
    tar czf $repo/sdcc.tgz sdcc
    popd
elif notDir $bdir/sdcc; then
    untar sdcc.tgz || return 1
fi
