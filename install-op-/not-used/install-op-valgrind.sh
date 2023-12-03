# ---------------------------------------------------------------------------- #
## \file install-op-valgrind.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=3.12.0
file=valgrind-$version.tar.bz2

download http://valgrind.org/downloads/$file || return 1
untar $file || return 1

if notWhich valgrind; then
    pushd $bdir/valgrind-$version || return 1
    ./autogen.sh >>$log
    ./configure >>$log 2>&1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi
