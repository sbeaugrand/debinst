#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 4updaterepo.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <name> [branch]"
    exit 1
fi
name=$1
if [ -n "$2" ]; then
    branch=$2
fi

source 0install.sh

# pull
pushd $bdir/$name || exit 1
if [ -n "$branch" ]; then
    sudo -u $user git checkout $branch
fi
sudo -u $user git pull --ff-only
popd

# tar
file=$repo/$name.tar
pushd $bdir || exit 1
echo tar cf $file $name/.git
eval tar cf $file $name/.git
popd
