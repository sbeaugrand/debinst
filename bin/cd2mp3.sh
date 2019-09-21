#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file cd2mp3.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ! which mpg123 >/dev/null 2>&1; then
    echo zypper install mpg123
    sudo zypper install mpg123 || exit 1
fi

dev="cdrom"
bitrate=192
m3u="00.m3u"
cddb="audio.cddb"

# ---------------------------------------------------------------------------- #
# icedax + cddb
# ---------------------------------------------------------------------------- #
size=0
if [ -f $cddb ]; then
    size=`stat -c%s $cddb`
fi
echo -n "icedax + cddb ? (O/n) "
read ret
if [ "$ret" != n ]; then
    which icedax >/dev/null 2>&1 || sudo zypper install icedax
    icedax -interface cooked_ioctl -D/dev/$dev -x -B -L0 -d99999 -Owav\
      2>&1 | tee diskid.txt
elif [ $size = 0 ]; then
    discid=`cat diskid.txt | grep "CDDB discid" | cut -dx -f2`
    genres="rock misc folk classical country blues\
            jazz newage reggae soundtrack data"
    n=1
    for i in $genres; do
        wget -O cddb.tmp http://www.freedb.org/freedb/$i/$discid 2> /dev/null
        if ((n < 10)); then
            echo -n " "
        fi
        echo "$n : "`grep DTITLE cddb.tmp | cut -d '=' -f 2`
        ((n = n + 1))
    done
    echo -n "? "
    read ret
    n=1
    for i in $genres; do
        if [ $n = $ret ]; then
            wget -O $cddb http://www.freedb.org/freedb/$i/$discid
        fi
        ((n = n + 1))
    done
fi

# ---------------------------------------------------------------------------- #
# encode
# ---------------------------------------------------------------------------- #
title=`grep DTITLE $cddb | sed 's/\ \/\ /=/g'`
artist=`echo $title | cut -d '=' -f 2`
album=`echo $title | cut -d '=' -f 3`
year=`grep DYEAR $cddb | cut -d '=' -f 2`
comment=`grep DISCID $cddb | cut -d '=' -f 2`
echo "artist=$artist"
echo "album=$album"
echo "year=$year"
echo "comment=$comment"
echo -n "continue ? (O/n) "
read ret
if [ "$ret" = n ]; then
    exit 0
fi
echo -n "bitrate ? [$bitrate] "
read ret
if [ -n "$ret" ]; then
    bitrate=$ret
fi
mkdir "$artist - $year - $album"
cd "$artist - $year - $album"
cddb="../$cddb"
last=`ls ../*.wav | tail -n 1 | cut -d '_' -f 2 | sed s/\.wav//g`
last=`echo ${last:0:2} | awk '{ print $0+0 }'`
for ((i = 0; i < last; i++)); do
    title=`grep "TTITLE$i=" $cddb | cut -d '=' -f 2`
    ((track = i + 1))
    mp3=`printf %02d $track`" - $title.mp3"
    if [ -f "$mp3" ]; then
        echo -n "$mp3 existe, ecraser ? (o/N) "
        read ret
        if [ "$ret" != o ]; then
            continue
        fi
    fi
    lame -s 44.1 -m j -q 0 -b $bitrate --cbr\
      --tt "$title"\
      --ta "$artist"\
      --tl "$album"\
      --tc "$comment"\
      --ty $year\
      --tn $track\
    ../audio_`printf %02d $track`.wav "$mp3"
done

# ---------------------------------------------------------------------------- #
# playlist
# ---------------------------------------------------------------------------- #
if [ -f $m3u ]; then
    echo -n "$m3u existe, ecraser ? (o/N) "
    read ret
    if [ "$ret" != o ]; then
        exit 0
    fi
    rm $m3u
fi
echo "#EXTM3U" > $m3u
for ((i = 0; i < last; i++)); do
    title=`grep "TTITLE$i=" $cddb | cut -d '=' -f 2`
    ((track = i + 1))
    mp3=`printf %02d $track`" - $title.mp3"
    time=`mpg123 -t "$mp3" 2>&1 | tail -n 1 | \
        awk -F '\\\[|:|]' '{ print $2 * 60 + $3 }'`
    echo "#EXTINF:$time,$artist - $title" >> $m3u
    echo "$mp3" >> $m3u
done
