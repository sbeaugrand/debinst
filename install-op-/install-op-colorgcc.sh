# ---------------------------------------------------------------------------- #
## \file install-op-colorgcc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
#repo=$idir/../repo

gitClone https://github.com/colorgcc/colorgcc.git || return 1

file=$bdir/colorgcc/colorgcc.pl
if isFile $file; then
    if notFile $home/.local/bin/gcc; then
        pushd $home/.local/bin || return 1
        cp $file g++
        cp $file gcc
        cp $file c++
        cp $file cc
        cp $file avr-g++
        cp $file avr-gcc
        popd
    fi
fi
