# ---------------------------------------------------------------------------- #
## \file install-op-mraa.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

if [ `uname -n` = "rockpi-s" ]; then
    gitClone https://github.com/radxa/mraa.git || return 1
else
    gitClone https://github.com/sbeaugrand/mraa.git || return 1
fi

dir=$bdir/mraa/build
if notDir $dir; then
    mkdir $dir
fi

if notFile /usr/local/lib/libmraa.so; then
    pushd $dir || return 1
    cmake >>$log 2>&1 $CMAKE_OPT ..
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
