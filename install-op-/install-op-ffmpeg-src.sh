# ---------------------------------------------------------------------------- #
## \file install-op-ffmpeg-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=ffmpeg
version=4.3.4
pkg=$name-$version.tgz
src=$name-apt-src
repo=$idir/../repo
ffmpeg=$name-$version

if notFile $repo/$pkg; then
    if notDir $bdir/$src; then
        mkdir $bdir/$src
    fi
    if notDir $bdir/$src/$ffmpeg; then
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
