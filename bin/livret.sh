#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file livret.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <pdf>"
    exit 0
fi
src="$1"
dst="livret-$1"
pdfxup -b -kbb -ow -o tmp-$dst $src >/dev/null
pdfjam -q --angle 90 -o $dst tmp-$dst
rm tmp-$dst
