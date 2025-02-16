#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file extractdeb.sh
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

dpkg-deb -c $file
echo "Todo:"
echo "dpkg-deb -x $file <dir>"
exit 0

data=`ar t $file | grep "data.tar"`
if [ "$data" = "data.tar.xz" ]; then
    ar p $file data.tar.xz | tar tJ | more
    echo "Todo:"
    echo "ar p $file data.tar.xz | tar xJ"
elif [ "$data" = "data.tar.gz" ]; then
    ar p $file data.tar.gz | tar tz | more
    echo "Todo:"
    echo "ar p $file data.tar.gz | tar xz"
else
    echo "data not found"
    exit 1
fi
