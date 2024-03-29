# ---------------------------------------------------------------------------- #
## \file install-op-m4acut.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
prefix=$home/.local

gitClone https://github.com/l-smash/l-smash.git || return 1
gitClone https://github.com/nu774/m4acut.git || return 1

if notWhich boxdumper; then
    pushd $bdir/l-smash || return 1
    ./configure --prefix=$prefix >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

if notWhich m4acut; then
    pushd $bdir/m4acut || return 1
    autoreconf -i >>$log 2>&1
    CFLAGS=-I$prefix/include\
  CPPFLAGS=-I$prefix/include\
   LDFLAGS=-L$prefix/lib\
     ./configure --prefix=$prefix >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
