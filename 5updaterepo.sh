#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 5updaterepo.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <name> [<branch>]"
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
    git checkout $branch
fi
git pull --ff-only
popd

# tar
repoSav=$repo
repo=$idir/../repo
file=$repo/$name.tar
if [ ! -f $file ]; then
    repo=$repoSav
    file=$repo/$name.tar
fi
pushd $bdir || exit 1
echo tar cf $file $name/.git
eval tar cf $file $name/.git
popd
