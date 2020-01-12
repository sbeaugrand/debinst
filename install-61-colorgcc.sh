# ---------------------------------------------------------------------------- #
## \file install-61-colorgcc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../colorgcc
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/colorgcc/colorgcc.git || return 1

file=$bdir/colorgcc/colorgcc.pl
if isFile $file; then
    if notLink $home/bin/gcc; then
        mkdir -p $home/bin
        pushd $home/bin || return 1
        ln -f $file g++
        ln -f $file gcc
        ln -f $file c++
        ln -f $file cc
        chown -R $user.$user .
        popd
    fi
fi
