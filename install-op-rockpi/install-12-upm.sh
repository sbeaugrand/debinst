# ---------------------------------------------------------------------------- #
## \file install-12-upm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone git://github.com/eclipse/upm.git || return 1

if notDir /usr/local/include/upm; then
    mkdir -p $bdir/upm/build
    pushd $bdir/upm/build || return 1
    cmake -DBUILDSWIGJAVA=OFF -DBUILDSWIGNODE=OFF -DBUILDSWIGPYTHON=OFF\
        $CMAKE_OPT .. >>$log 2>&1
    make >>$log 2>&1 install/fast
    popd
fi

if notLink /usr/local/lib/libupm-lcd.so; then
    pushd $bdir/upm/build/src/lcd || return 1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
