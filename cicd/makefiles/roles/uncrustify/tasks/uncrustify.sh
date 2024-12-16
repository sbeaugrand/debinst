#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file uncrustify.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "-n" ]; then
    interactive=0
    shift
else
    interactive=1
fi
count=0

if [ -z "$1" ]; then
    list=`find . -type d \( -name build -o -name build-* -o -name .vagrant \)\
 -prune -false -o \( -name "*.[ch]" -o -name "*.cpp" \) -print |\
 grep -v "/doc/" | cut -c3-`
else
    list="$*"
fi

for f in $list; do
    dir=`dirname $f`
    path=""
    for d in `echo $dir | tr '/' ' '`; do
        path="$path$d/"
        if [ -f "$path/.git" ]; then
            dir=""
            break
        fi
    done
    base=`basename $f`
    if [ -z "$dir" ] || grep -q "^$base$" $dir/uncrustify.supp 2>/dev/null; then
        echo "      skip $f"
        continue
    else
        echo "uncrustify $f"
    fi
    uncrustify -q -c ~/.uncrustify.cfg -o $f.tmp -f $f
    if ! diff $f $f.tmp >/dev/null; then
        ((count++))
        if ((interactive)); then
            diff -y -W 168 $f $f.tmp | colordiff | more
            echo -n "ecraser ? (o/N) "
            read ret
            if [ "$ret" = o ]; then
                cp $f.tmp $f
            fi
        else
            diff $f $f.tmp
        fi
    fi
    rm $f.tmp
done

if ((count > 255)); then
    count=255
fi
exit $count
