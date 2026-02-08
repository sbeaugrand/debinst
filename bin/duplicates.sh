#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file duplicates.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "-f" ]; then
    rm="rm"
else
    rm="echo rm"
    echo
    echo "Usage: `basename $0` [-f]"
    echo
fi

tmp=/tmp/duplicates.tmp
ls -1 *\ \([0-9]*\).* >$tmp
size=`cat $tmp | wc -l`
for ((i = 1; i <= size; ++i)); do
    new=`head -n $i $tmp | tail -n 1`
    old=`echo $new | sed 's/\(.*\) (.*)\.\(.*\)/\1.\2/'`
    if diff -q "$old" "$new" >/dev/null 2>&1; then
        $rm "$new"
    fi
done
rm $tmp
