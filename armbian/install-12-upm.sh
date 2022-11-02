# ---------------------------------------------------------------------------- #
## \file install-12-upm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/eclipse/upm.git || return 1

if [ -f /boot/armbianEnv.txt ]; then
    prefix=/usr/local
else
    prefix=$home/.local
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$prefix/lib/pkgconfig
fi

if notDir $prefix/include/upm; then
    mkdir -p $bdir/upm/build
    pushd $bdir/upm/build || return 1
    cmake >>$log 2>&1 -DCMAKE_INSTALL_PREFIX=$prefix $CMAKE_OPT\
        -DBUILDSWIGJAVA=OFF -DBUILDSWIGNODE=OFF -DBUILDSWIGPYTHON=OFF ..
    make >>$log 2>&1 install/fast
    popd
fi

if notLink $prefix/lib/libupm-lcd.so; then
    pushd $bdir/upm/build/src/lcd || return 1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
    if [ -f /boot/armbianEnv.txt ]; then
        /usr/sbin/ldconfig /usr/local/lib
    fi
fi
