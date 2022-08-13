# ---------------------------------------------------------------------------- #
## \file install-op-mplayer-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=mplayer
version=1.4+ds1
pkg=$name-$version.tgz
src=$name-apt-src
repo=$idir/../repo
mplayer=$name-$version

if notFile $repo/$pkg; then
    if notDir $bdir/$src; then
        mkdir $bdir/$src
    fi
    if notDir $bdir/$src/$mplayer; then
        pushd $bdir/$src || return 1
        apt-get source $name
        dpkg-source -x ${name}_${version}*.dsc
        chown -R $user.$user $bdir/$src
        popd
    fi
    pushd $bdir/$src || return 1
    tar czf $repo/$pkg $name-$version
    popd
fi

untar $pkg || return 1
