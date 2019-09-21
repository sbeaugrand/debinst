# ---------------------------------------------------------------------------- #
## \file install-op-mp3gain.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.5.2
file=mp3gain-1_5_2-src.zip

repo=$idir/../mp3gain
[ -d $repo ] || sudo -u $user mkdir $repo

download http://distfiles.gentoo.org/distfiles/$file || return 1

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
    make install >>$log 2>&1
    popd
fi
