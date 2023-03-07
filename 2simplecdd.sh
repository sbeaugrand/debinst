#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 2simplecdd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <simplecdd-...> <buildpackage-...>"
    exit 1
fi
simplecdd=$1
lpkg=$2

source 0install.sh

# ---------------------------------------------------------------------------- #
# removeInMirror
# ---------------------------------------------------------------------------- #
removeInMirror()
{
    pkg=$1
    mirror=$2
    if [ -d $mirror ]; then
        pushd $mirror
        reprepro remove stable $pkg >>$log 2>&1
        popd
    fi
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
for i in `cat $lpkg/list.txt`; do
    removeInMirror $i $bdir/$simplecdd/tmp/mirror
done

cd $simplecdd
make LPKG=$lpkg
stat -c '%s' $bdir/$simplecdd/images/debian-*-DVD-1.iso |\
 awk '{ printf "%.1f GB\n",$0 / 1e9 }'
