#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file split.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
smtpLimit=200

if [ -z "$1" ]; then
    echo "Usage: `basename $0` <file>"
    exit 1
else
    file=$1
fi

n=`cat $file | wc -l`
n=$(($n / ($n / $smtpLimit + 1) + 1))
echo "n=$n"
sed -e 's/^/\t/' -e 's/$/,/' $file |\
 split -l $n --additional-suffix=.list -d - x-pr-
