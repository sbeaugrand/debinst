#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3untar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$MP3DIR" ]; then
    echo "Usage: MP3DIR=<dir> `basename $0`"
    exit 1
fi
new=$MP3DIR/mp3/new

# ---------------------------------------------------------------------------- #
# \fn update
# ---------------------------------------------------------------------------- #
update()
{
    lst=$1
    tmp=/tmp/mp3untar.tmp
    cd $MP3DIR/mp3

    diff mp3.list $lst | grep "^[<>]" | LC_ALL=C sort -t '/' -k 2 >$tmp
    cat $tmp

    n=`cat $tmp | wc -l`
    for ((i = 1; i <= n; ++i)); do
        f1=`head -n $i $tmp | tail -n 1 | cut -c3- | sed 's#/00.m3u##'`
        b1=`echo "$f1" | cut -d '/' -f 2-`
        ((++i))
        f2=`head -n $i $tmp | tail -n 1 | cut -c3- | sed 's#/00.m3u##'`
        b2=`echo "$f2" | cut -d '/' -f 2-`
        if [ "$b1" != "$b2" ]; then
            echo "!  $b1"
            echo "!= $b2"
            ((--i))
            f2=`find . -type d -name "$b1" | grep -v new | grep "$b1"`
            if [ -z "$f2" ]; then
                continue
            fi
            echo -n "rm -fr $f2 (O/n) "
            read ret
            if [ "$ret" = n ]; then
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
    cd - >/dev/null
}

# ---------------------------------------------------------------------------- #
# untar
# ---------------------------------------------------------------------------- #
cd $new || exit 1
ls *.tar | xargs -t -I {} tar xf {}
if diff -q $MP3DIR/mp3/mp3.list $new/mp3.list; then
    exit 0
fi

# ---------------------------------------------------------------------------- #
# update
# ---------------------------------------------------------------------------- #
echo -n "update ? (O/n) "
read ret
if [ "$ret" != n ]; then
    mp3rand.sh -r
    update $new/mp3.list
    mp3rand.sh -r
fi

# ---------------------------------------------------------------------------- #
# rm
# ---------------------------------------------------------------------------- #
cmd="ls $new/*.tar | xargs -I {} rm -vf {}"
echo -n "$cmd ? (O/n) "
read ret
if [ "$ret" != n ]; then
    eval $cmd
fi
