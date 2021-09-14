#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file archive.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
archive="mail-pr-.7z"

if [ -n "$1" ]; then
    # extract :
    # ./archive.sh x
    if [ $1 = x ] && [ -f mail-pr-.list ]; then
        echo "mail-pr-.list found"
        exit 1
    fi
    7z $* $archive
else
    # add :
    # ./archive.sh
    if [ ! -f mail-pr-.list ]; then
        echo "mail-pr-.list not found"
        exit 1
    fi
    rm -f $archive
    7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p $archive *-pr- *-pr-*.list *-pr-*.supp *-pr-*.txt
fi
