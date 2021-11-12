# ---------------------------------------------------------------------------- #
## \file install-op-433Utils.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=433Utils

if notDir $bdir/$name; then
    pushd $bdir || return 1
    gitClone https://github.com/ninjablocks/$name.git || return 1
    popd
fi

if notFile $bdir/$name/rc-switch/RCSwitch.cpp; then
    pushd $bdir/$name || return 1
    git submodule init
    git submodule update
    popd
fi

dir=$bdir/$name/RPi_utils
file=$dir/RFSniffer.cpp
if notGrep 'PIN = 16' $file; then
    sed -i 's/PIN = 2/PIN = 16/' $file
fi

if notFile $dir/RFSniffer; then
    pushd $dir || return 1
    make
    popd
fi
