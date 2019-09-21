#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file rkill.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    exit 0
fi

# ---------------------------------------------------------------------------- #
# treekill
# ---------------------------------------------------------------------------- #
treekill()
{
    childs=`ps -ef | awk '$3 == '$1' { print $2 }'`
    name=`ps -p $1 | tail -n 1 | awk '{ print $NF }'`
    if kill -9 $1 2>/dev/null; then
        echo "$level$name($1) killed"
    else
        echo "$level$name($1) not found"
    fi
    levelprec=$level
    level="$level  "
    for c in $childs; do
        treekill $c
    done
    level=$levelprec
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
for i in $*; do
    level=""
    treekill $i
done
