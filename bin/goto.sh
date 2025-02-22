#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file goto.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <file>[:<line>[:<col>]]"
    exit 1
fi
name=`echo $1 | cut -d ':' -f 1`
line=`echo $1 | cut -d ':' -f 2`

if [ ${name:0:1} = "/" ]; then
    file=$name
else
    file=`find . -name "${name##*/}" -print |\
     grep "$name" | tee /dev/stderr | head -n 1`
fi

if [ "$line" = "$1" ]; then
    vi "$file"
    exit $?
fi

col=`echo $1 | cut -d ':' -f 3`
if [ -n "$col" ]; then
    vi "$file" +$line +"norm 0" +"norm $(($col - 1))l"
else
    vi "$file" +$line
fi
