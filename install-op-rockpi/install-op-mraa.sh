# ---------------------------------------------------------------------------- #
## \file install-op-mraa.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../mraa
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/eclipse/mraa.git || return 1

dir=$bdir/mraa/build
if notDir $dir; then
    mkdir $dir
fi

if notFile /usr/local/lib/libmraa.so; then
    pushd $dir || return 1
    cmake\
     -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc\
     -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++\
     .. >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
