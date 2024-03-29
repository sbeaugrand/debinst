# ---------------------------------------------------------------------------- #
## \file install-op-mp3gain.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.6.2
file=mp3gain-1_6_2-src.zip
repo=$idir/../repo

download https://distfiles.gentoo.org/distfiles/2b/$file || return 1

if notDir $bdir/mp3gain-$version; then
    pushd $bdir || return 1
    mkdir mp3gain-$version
    popd

    pushd $bdir/mp3gain-$version || return 1
    unzip $repo/$file >>$log
    popd
fi

if notWhich mp3gain; then
    pushd $bdir/mp3gain-$version || return 1
    make >>$log 2>&1
    cp mp3gain $home/.local/bin/
    popd
fi
