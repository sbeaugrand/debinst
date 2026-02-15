#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3diff.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
list=mps.list
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <$list.new>"
    exit 0
fi

if [ -n "$MP3DIR" ]; then
    dir="$MP3DIR/mp3"
else
    dir=/mnt/mp3/mp3
fi
new=`readlink -f $1`
cd $dir

tmp=/tmp/mp3diff.tmp
diff $list $new | grep "^[<>]" | LC_ALL=C sort -t '/' -k 2 > $tmp
cat $tmp

n=`cat $tmp | wc -l`
for ((i = 1; $i <= $n; ++i)); do
    f1=`head -n $i $tmp | tail -n 1 | cut -c3- | sed 's/\/00.m3u//'`
    b1=`echo "$f1" | cut -d '/' -f 2-`
    ((++i))
    f2=`head -n $i $tmp | tail -n 1 | cut -c3- | sed 's/\/00.m3u//'`
    b2=`echo "$f2" | cut -d '/' -f 2-`
    if [ "$b1" != "$b2" ]; then
        echo "!  $b1"
        echo "!= $b2"
        ((--i))
        f2=`find . -type d -name "$b1" | grep -v new | grep "$b1"`
        if [ -z "$f2" ]; then
            continue
        fi
        echo -n "rm -fr $f2 (o/N) "
        read ret
        if [ "$ret" != o ]; then
            continue
        fi
        rm -fr "$f2"
    fi
    echo    "mv $f1"
    echo -n "to $f2 (O/n) "
    read ret
    if [ "$ret" != n ]; then
        eval mv \"$f1\" \"$f2\"
    fi
done

rm $tmp
