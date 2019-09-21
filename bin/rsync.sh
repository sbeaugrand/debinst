#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file rsync.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
log=/tmp/rsync.log
quit()
{
    shred -u -z $log;
    exit $1
}
trap "echo; quit 0" SIGINT

if [ -z "$2" ]; then
    echo "Usage: `basename $0` <src> <dst> <options>"
    quit 1
fi
src=${1%%/}
shift
dst=${1%%/}
shift
if [ -d $src ] && ([ ! -e $dst ] || [ -d $dst ]); then
    src=$src/
    dst=$dst/
elif [ ! -f $src ] || ([ -e $dst ] && [ ! -f $dst ]); then
    echo "erreur: fichiers ou dossiers mais pas les deux"
    quit 1
fi

if [ "$1" = "--no-delete" ]; then
    shift
    sync="rsync --checksum -aO -f '- *~' $*"
else
    sync="rsync --checksum --delete -aO -f '- *~' $*"
fi

eval $sync -ni $src $dst >$log
if [ ! -s $log ]; then
    quit 0
fi
sort -k 2 $log | more
echo -n "`cat $log | wc -l` files"
echo -n " - proceed ? [Y/n/p/a] "
read ret

if [ "$ret" != p ]; then
    sync="$sync -i"
fi
if [ "$ret" = p ] || [ "$ret" = a ]; then
    if which colordiff >/dev/null 2>&1; then
        colordiff=colordiff
    else
        colordiff=cat
    fi
    n=`cat $log | wc -l`
    for ((i=1;$i<=$n;i++)); do
        f=`head -n $i $log | tail -n 1`
        if echo "$f" | grep deleting >/dev/null; then
            continue
        fi
        if echo "$f" | grep delete >/dev/null; then
            continue
        fi
        if [ "$ret" != a ]; then
            echo -n "$f ? [Y/n/d/a] "
            read ret
            if [ "$ret" = n ]; then
                continue
            fi
        fi
        f=`echo "$f" | cut -d ' ' -f 2- | awk -F ' -> ' '{ print $1 }'`
        if [ "$ret" = d ]; then
            if [ -d $src ]; then
                diff "$dst/$f" "$src/$f" | $colordiff
            else
                diff $dst $src | $colordiff
            fi
            echo -n "$f ? [Y/n] "
            read ret
            if [ "$ret" = n ]; then
                continue
            fi
        fi
        if [ -d $src ]; then
            eval $sync "$src/$f" "$dst/$f"
        else
            eval $sync $src $dst
        fi
    done
    ret=n
fi
echo
if [ "$ret" != n ]; then
    eval $sync $src $dst
fi
quit $?
