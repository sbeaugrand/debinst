#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3gain.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
mp3d=/tmp/mp3d.tmp
mp3g=/tmp/mp3g.tmp
mp3s=/tmp/mp3s.tmp

find . -type d -print | LC_ALL=C sort >$mp3d
ndir=`cat $mp3d | wc -l`
trap "rm $mp3d $mp3g $mp3s; echo; exit 0" SIGINT

if [ "$1" = "-f" ]; then
    force=1
fi

# ---------------------------------------------------------------------------- #
# rdexec
# ---------------------------------------------------------------------------- #
rdexec()
{
    for ((rj = 1; $rj <= $ndir; rj++)); do
        rd=`head -n $rj $mp3d | tail -n 1`
        eval $1 \""$rd"\" \""$2"\"
    done
}

# ---------------------------------------------------------------------------- #
# gain
# ---------------------------------------------------------------------------- #
gain()
{
    cd "$1"
    if [ -n "$force" ]; then
        mp3gain -r -k *.mp3 | grep Applying
        return
    fi
    mp3gain -x -p *.mp3 >$mp3g
    find . -maxdepth 1 -name "*.mp3" -print | LC_ALL=C sort >$mp3s
    nmp3=`cat $mp3s | wc -l`
    clip=0
    noclip=0
    for ((ri = 1; $ri <= $nmp3; ri++)); do
        rf=`head -n $ri $mp3s | tail -n 1 | sed 's@^./@@'`
        if grep "file $rf" $mp3g >/dev/null; then
            clip=1
            if [ $noclip = 1 ]; then
                break;
            fi
        else
            noclip=1
            if [ $clip = 1 ]; then
                break;
            fi
        fi
    done
    if [ $clip = 1 ] && [ $noclip = 1 ]; then
        echo "$1"
        for ((ri = 1; $ri <= $nmp3; ri++)); do
            rf=`head -n $ri $mp3s | tail -n 1 | sed 's@^./@@'`
            if grep "file $rf" $mp3g >/dev/null; then
                echo -n "* "
            else
                echo -n "  "
            fi
            echo "$rf"
        done
        echo -n "(O/n) ? "
        read ret
        if [ "$ret" != n ]; then
            mp3gain -r -k *.mp3 | grep Applying
        fi
    fi
    rm $mp3s
    rm $mp3g
    cd - >/dev/null 2>&1
}

rdexec gain

rm $mp3d
exit 0
