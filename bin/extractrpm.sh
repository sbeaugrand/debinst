#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file extractrpm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    file=$1
else
    echo "Usage: `basename $0` <file>"
    exit 1
fi

rpm2cpio $1 | cpio --list
echo "Todo:"
echo "rpm2cpio $1 | cpio --extract --make-directories"
