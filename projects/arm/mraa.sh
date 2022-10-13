# ---------------------------------------------------------------------------- #
## \file mraa.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

if [ `uname -n` = "rockpi-s" ]; then
    gitClone https://github.com/radxa/mraa.git || return 1
    CMAKE_OPT="-DBUILDSWIG=OFF"
    file=$bdir/mraa/include/version.h
    if notGrep "extern const char" $file; then
        sed -i 's/^const char/extern const char/' $file
    fi
else
    gitClone https://github.com/sbeaugrand/mraa.git || return 1
fi

dir=$bdir/mraa/build
if notDir $dir; then
    mkdir $dir
fi

if [ -f /boot/armbianEnv.txt ]; then
    prefix=/usr/local
else
    prefix=$home/.local
fi

if notFile $prefix/lib/libmraa.so; then
    pushd $dir || return 1
    cmake >>$log 2>&1 -DCMAKE_INSTALL_PREFIX=$prefix $CMAKE_OPT ..
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

if [ -f /boot/armbianEnv.txt ]; then
    /sbin/ldconfig
fi
