#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file uncrustify.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    list=`find . -type d -name build -prune -false -o\
 \( -name "*.[ch]" -o -name "*.cpp" \) -print | grep -v "/doc/"`
else
    list="$*"
fi
for f in $list; do
    if [ -L $f ]; then
        continue
    fi
    echo "uncrustify $f"
    uncrustify -q -c ~/.uncrustify.cfg -o $f.tmp -f $f
    if ! diff $f $f.tmp >/dev/null; then
        diff -y -W 168 $f $f.tmp | colordiff | more
        echo -n "ecraser ? (o/N) "
        read ret
        if [ "$ret" = o ]; then
            mv $f.tmp $f
        else
            rm $f.tmp
        fi
    else
        rm $f.tmp
    fi
done
