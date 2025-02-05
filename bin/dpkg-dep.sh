#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file dpkg-dep.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note dpkg-dep.sh >deps
##       cat deps | cut -d')' -f1 | cut -d'(' -f2 | sort | uniq -c | sort -n
##       grep ... deps
##       dpkg-dep.sh ...
##       apt show ... | grep Depends
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    aptitude -v --show-summary=all-packages why $*
    exit $?
fi

file=~/install/debinst/simplecdd-op-1arch64/list.txt
list=`sed 's/#.*//' $file`
for p in $list; do
    rdeps=`aptitude -v --show-summary=all-packages why $p |\
 sed -e 's/R:.*//' -e 's/F<-.*//' -e 's/$/ /' |\
 grep "D: *$p " | awk '{ print $1 }' | sort -u`
    for r in $rdeps; do
        if [ $r != $p ]; then
            sed 's/#.*//' $file | grep "^$r" | sed "s/$/ ($p)/"
        fi
    done
done
