# ---------------------------------------------------------------------------- #
## \file install-op-sdcc-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
[ -d $idir/../sdcc ] || sudo -u $user mkdir $idir/../sdcc

if notFile $idir/../sdcc/sdcc.tgz; then
    if notDir $repo/sdcc; then
        mkdir $repo/sdcc
    fi
    if notDir $repo/sdcc/gputils; then
        pushd $repo/sdcc || return 1
        svn checkout svn://svn.code.sf.net/p/gputils/code/trunk gputils >>$log
        popd
    fi
    if notDir $repo/sdcc/sdcc; then
        pushd $repo/sdcc || return 1
        svn checkout svn://svn.code.sf.net/p/sdcc/code/trunk sdcc >>$log
        popd
    fi
    pushd $repo || return 1
    tar czf $idir/../sdcc/sdcc.tgz sdcc
    popd
fi

repo=$idir/../sdcc
untar sdcc.tgz || return 1
