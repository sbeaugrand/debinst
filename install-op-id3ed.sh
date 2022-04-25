# ---------------------------------------------------------------------------- #
## \file install-op-id3ed.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.10.4
file=id3ed-$version.tar.gz
repo=$idir/../repo

download http://distfiles.gentoo.org/distfiles/$file || return 1
untar $file || return 1

if notWhich id3ed; then
    pushd $bdir/id3ed-$version || return 1
    ./configure --prefix=$home/.local >>$log 2>&1
    mkdir -p $home/.local/share/man/man1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
