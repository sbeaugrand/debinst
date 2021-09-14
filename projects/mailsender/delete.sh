#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file delete.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "-n" ]; then
    delete=n
    shift
else
    delete=y
fi
if [ -z "$2" ]; then
    echo "Usage: $0 <mail-pr-.list> <mail-pr-.supp>"
    exit 1
fi
list="$1"
supp="$2"

n=`cat $supp | wc -l`

for ((i = 1; i <= n; i++)); do
    a=`cat $supp | head -n $i | tail -1`
    if [ $delete = y ]; then
        sed -i "/^$a$/d" $list
    else
        grep "^$a$" $list
    fi
done
true
