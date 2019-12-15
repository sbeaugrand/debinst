#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 4updaterepo.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <name> <branch>"
    exit 1
fi
name=$1
branch=$2

source 0install.sh

# pull
pushd $bdir/$name || exit 1
sudo -u $user git checkout $branch
sudo -u $user git pull --ff-only
popd

# tar
file=$repo/$name.tgz
pushd $bdir || exit 1
echo tar czf $file $name/.git
eval tar czf $file $name/.git
popd
