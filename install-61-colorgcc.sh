# ---------------------------------------------------------------------------- #
## \file install-61-colorgcc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

gitClone https://github.com/colorgcc/colorgcc.git || return 1

dir=$home/.local/bin
if notDir $dir; then
    mkdir -p $dir
fi

file=$bdir/colorgcc/colorgcc.pl
if isFile $file; then
    if notFile $dir/gcc; then
        pushd $dir || return 1
        cp $file g++
        cp $file gcc
        cp $file c++
        cp $file cc
        cp $file avr-g++
        cp $file avr-gcc
        chown -R $user.$user .
        popd
    fi
fi
