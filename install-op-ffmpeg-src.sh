# ---------------------------------------------------------------------------- #
## \file install-op-ffmpeg-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
#file=ffmpeg-3.2.9.tar.xz

#repo=$idir/../ffmpeg
#[ -d $repo ] || sudo -u $user mkdir $repo

#download https://ffmpeg.org/releases/$file || return 1
#untar $file || return 1

#return 0

name=ffmpeg
version=4.1.3
pkg=$name-$version.tgz
src=$name-apt-src

repo=$idir/../$name
[ -d $repo ] || sudo -u $user mkdir $repo

if notFile $repo/$pkg; then
    if notDir $bdir/$src; then
        mkdir $bdir/$src
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
