#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3rand.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Les albums doivent etre ranges dans des repertoires commencants par
##       part01, part02, etc. A chaque repertoire doit etre associe' un poids.
##       Les albums doivent etre des repertoires. Dans chaque album il doit y
##       avoir une liste 00.m3u
# ---------------------------------------------------------------------------- #
# part : 1 2 3 4 5 6 7       1 2 3
weights="8 7 6 5 4 3 2 6 4 2 3 2 1 3 2 1"

if [ -n "$MP3DIR" ]; then
    dir="$MP3DIR"
else
    dir=/data
fi
list=$dir/mp3/mp3.list
log=$MP3DIR/.mp3log
tmpfile=/tmp/mp3list.tmp
lastdate=$MP3DIR/.mp3date

# ---------------------------------------------------------------------------- #
# usage
# ---------------------------------------------------------------------------- #
if [ "$1" = "-h" ]; then
    cat <<EOF

Usage: ${0##*/} [options]
Options:
-i [artiste]    informations sur les albmus de l'artiste ou sur le dernier album
-r              generation de la liste
["path/00.m3u"] lire la liste $dir/path/00.m3u
EOF
    exit 0
fi

if [ ! -d "$dir" ]; then
    echo "$dir n'est pas un repertoire"
    exit 1
fi
if [ ! -d "$dir/mp3" ]; then
    echo "$dir/mp3 n'est pas un repertoire"
    exit 1
fi

# ---------------------------------------------------------------------------- #
# reset
# ---------------------------------------------------------------------------- #
if [ "$1" = "-r" ] || [ ! -r "$list" ]; then
    echo "generation du fichier $list ..."
    cd "$dir/mp3"
    find -L . -name 00.m3u -print | LC_ALL=C sort | cut -c3- >"$list"
    exit $?
fi

# ---------------------------------------------------------------------------- #
# info
# ---------------------------------------------------------------------------- #
if [ "$1" = "-i" ]; then
    cd "$dir/mp3"
    if [ -n "$2" ]; then
        album=`grep "/$2 -" $log | tail -n 1 | cut -d "/" -f 2`
        artist="$2"
    else
        album=`tail -n 1 $log | cut -d "/" -f 2`
        artist=`echo "$album"  | cut -d "-" -f 1 | sed 's/ $//'`
        grep "/$album" $log | tail -n 2 | head -n 1
        echo
    fi

    grep "/$artist - " "$list" | sed 's/\/00\.m3u//' | sed 's/\ /\\\ /g' |\
      sed 's/(/\\(/g' | sed 's/)/\\)/g' | sed "s/'/\\\'/g" |\
      awk '{ print "grep "$0" mp3.list | sed \"s/^/           /\" |\
      sed \"s/\\/00\\.m3u//\" | cat - '$log' | grep "$0"$ | tail -n 1" }' |\
      awk '{ system($0) }' | tee /tmp/mp3rand-i.tmp
    exit $?
fi

# ---------------------------------------------------------------------------- #
# updatelog
# ---------------------------------------------------------------------------- #
updatelog()
{
    jour=`date +%F`
    heure=`date +%R`
    last=`echo "$jour $heure" | sed 's/-/ /g' | sed 's/:/ /'`
    prev=`cat $lastdate 2>/dev/null | sed 's/-/ /g' | sed 's/:/ /'`
    if [ -n "$prev" ]; then
        i=0
        for a in $prev; do
            prevtab[$i]=`echo $a | awk '{ print $0+0 }'`
            ((i++))
        done
        i=0
        for a in $last; do
            lasttab[$i]=`echo $a | awk '{ print $0+0 }'`
            ((i++))
        done
        ((min = (lasttab[0] - prevtab[0]) * 525600 +
                (lasttab[1] - prevtab[1]) * 44640 +
                (lasttab[2] - prevtab[2]) * 1440 +
                (lasttab[3] - prevtab[3]) * 60 +
                (lasttab[4] - prevtab[4]) ))
        if [ -n "$min" ]; then
            if ((min < 2)); then
                echo "derniere selection il y a $min minute"
            else
                echo "derniere selection il y a $min minutes"
            fi
            if [ ! -f $log ]; then
                touch $log
            elif ((min < 5)); then
                echo "effacement de la derniere selection"
                nl=`cat $log | wc -l`
                if ((nl > 0)); then
                    ((nl--))
                    head -n $nl $log >$log.tmp
                    mv $log.tmp $log
                fi
            fi
        fi
    fi
    echo $jour" $m3u" | sed 's/\/00\.m3u//' >>$log
    echo "$last" >$lastdate
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    max=0
    m=`ls "$dir/mp3" | grep part | tail -n 1`
    m=`echo ${m:4:2} | awk '{ print $0+0 }'`
    n=0
    for i in $weights; do
        ((max = max + i))
        ((n++))
    done
    if ((n != m)); then
        echo "les nombres de poids ne correspondent pas"
        exit 1
    fi
    ((rand = RANDOM * max / 32768 + 1))
    part=1
    max=0
    for i in $weights; do
        ((max = max + i))
        if ((rand <= max)); then
            break;
        fi
        ((part++))
    done

    part="part"`printf %02d $part`
    grep $part "$list" >$tmpfile
    max=`cat $tmpfile | wc -l`
    ((num = RANDOM * max / 32768 + 1))
    m3u=`head -n $num $tmpfile | tail -n 1`
    rm $tmpfile
else
    m3u=$1
fi

updatelog
m3u=`echo "$dir/mp3/$m3u" | sed "s/'/\\\\\'/g"`

album=`tail -n 1 $log | cut -d "/" -f 2`
grep "/$album" $log | tail -n 2 | head -n 1

nyxmms2 stop
nyxmms2 clear
nyxmms2 addpls "$m3u"
nyxmms2 play
