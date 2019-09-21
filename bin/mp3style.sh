#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3style.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Trouver les répertoires sans liste m3u :
#  find . -type d -exec test ! -f {}/00.m3u \; -print
# ---------------------------------------------------------------------------- #
if [ "$1" = "-i" ]; then
    interactive=1
else
    interactive=0
fi

if ! which id3ed >/dev/null 2>&1; then
    echo "error: id3ed not found"
    exit 1
fi
if ! which mpg123 >/dev/null 2>&1; then
    echo "error: mpg123 not found"
    exit 1
fi
if ! which id3v2 >/dev/null 2>&1; then
    echo "error: id3v2 not found"
    exit 1
fi

if find . -print | grep -P "[^a-zA-Z0-9()',./ [\]_%+-]"; then
    exit 1
fi

dirs=mp3style-dir.tmp
mp3s=mp3style-mp3.tmp
find . -type d -print | LC_ALL=C sort >$dirs
ndir=`cat $dirs | wc -l`
trap "rm $dirs; echo; exit 0" SIGINT

# ---------------------------------------------------------------------------- #
# rdexec
# ---------------------------------------------------------------------------- #
rdexec()
{
    for ((rj=1;$rj<=$ndir;rj++)); do
        rd=`head -n $rj $dirs | tail -n 1`
        eval $1 \""$rd"\" \""$2"\"
    done
}

# ---------------------------------------------------------------------------- #
# rfexec
# ---------------------------------------------------------------------------- #
rfexec()
{
    cd "$1"
    find . -maxdepth 1 -name "*.mp3" -print | LC_ALL=C sort >$mp3s
    nmp3=`cat $mp3s | wc -l`
    for ((ri=1;$ri<=$nmp3;ri++)); do
        rf=`head -n $ri $mp3s | tail -n 1`
        eval $2 \""$rf"\"
    done
    rm $mp3s
    cd - >/dev/null 2>&1
}

# ---------------------------------------------------------------------------- #
# fffb
# ---------------------------------------------------------------------------- #
fffb()
{
    echo -n "$1"
    s=`hexdump -e '/1 "%02X"' -v "$1" | grep -b -o FFFB | \
        head -n 1 | cut -d ':' -f 1`
    if [ -n "$s" ] && ((s > 1)); then
        s=`echo $s | awk '{ print rshift($0,1) }'`
        echo -n " $s"
        dd status=noxfer if="$1" ibs=$s skip=1 of=mp3.tmp 2>/dev/null
        mv mp3.tmp "$1"
    fi
    echo
}

# ---------------------------------------------------------------------------- #
# ucfirst
# ---------------------------------------------------------------------------- #
ucfirst()
{
    echo "$1"
    echo "$1" | cut -c3- |\
    awk 'BEGIN { FS = " *|_" } {
      printf "mv \"%s\" \"", $0
      for(j=1;j<=NF;j++) {
        size = length($j)
        printf "%c",toupper(substr($j,1,1))
        for(i=2;i<=size;i++) {
          if (substr($j,i-1,1) == "(") {
            printf "%s",toupper(substr($j,i,1))
          } else {
            printf "%c",tolower(substr($j,i,1))
          }
        }
        if (j<NF)
          printf " "
      }
      printf "\"\n"
    }' |\
    awk '{ system($0) }' 2>/dev/null
}

# ---------------------------------------------------------------------------- #
# tag
# ---------------------------------------------------------------------------- #
tag()
{
    echo "$1"
    size=`stat -c "%s" "$1"`
    if ((size == 0)); then
        return
    fi
    f=`basename "$1"`
    i=`echo ${f:0:2} | awk '{ print $0+0 }'`
    id3v2 -D "$f" >/dev/null
    title=`echo "${f%.mp3}" | cut -c6-`
    id3ed -n "$artist" -a "$album" -y "$year" -k $i -s "$title" -q "$f" \
        >/dev/null
}

# ---------------------------------------------------------------------------- #
# rtag
# ---------------------------------------------------------------------------- #
rtag()
{
    dir="$1"
    if [ "$dir" = "." ]; then
        dir=`pwd`
    fi
    dir=${dir##*/}
    artist=`echo "$dir" | awk -F ' - ' '{ print $1 }'`
      year=`echo "$dir" | awk -F ' - ' '{ print $2 }'`
     album=`echo "$dir" | awk -F ' - ' '{ print $3 }'`
    echo "artist=$artist year=$year album=$album"
    if [ -z "$album" ]; then
        return
    fi
    rfexec "$1" tag
}

# ---------------------------------------------------------------------------- #
# list
# ---------------------------------------------------------------------------- #
list()
{
    echo "$1"
    size=`stat -c "%s" "$1"`
    if ((size == 0)); then
        echo "warn: size = 0"
        return
    fi
    f=`basename "$1"`
    i=`echo ${f:0:2} | awk '{ print $0+0 }'`
    title=`echo "${f%.mp3}" | cut -c6-`
    mp3=`printf %02d $i`" - $title.mp3"
    time=`mpg123 -t "$mp3" 2>&1 | tail -n 1`
    time=`echo $time | cut -d ']' -f 1 | cut -d '[' -f 2 |\
        awk -F ':' '{ print $1 * 60 + $2 }'`
    if ((time == 0)); then
        echo "warn: time = 0"
        return
    fi
    echo "#EXTINF:$time,$artist - $title" >>00.m3u
    echo "$mp3" >>00.m3u
}

# ---------------------------------------------------------------------------- #
# rlist
# ---------------------------------------------------------------------------- #
rlist()
{
    dir="$1"
    if [ "$dir" = "." ]; then
        dir=`pwd`
    fi
    dir=${dir##*/}
    artist=`echo "$dir" | awk -F ' - ' '{ print $1 }'`
      year=`echo "$dir" | awk -F ' - ' '{ print $2 }'`
     album=`echo "$dir" | awk -F ' - ' '{ print $3 }'`
    echo "artist=$artist year=$year album=$album"
    if [ -z "$album" ]; then
        return
    fi
    echo "#EXTM3U" >"$1/00.m3u"
    rfexec "$1" list
}

# ---------------------------------------------------------------------------- #
# myRead
# ---------------------------------------------------------------------------- #
myRead()
{
    if [ $interactive = 0 ]; then
        return 0
    fi

    echo -n "$1 ? (o/N) "
    read ret
    if [ "$ret" != o ]; then
        return 1
    else
        return 0
    fi
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
myRead "rchmod644" && find . -type f -exec chmod 644 {} \;
myRead "fffb"      && rdexec rfexec fffb
myRead "dirnames"  && rdexec ucfirst
find . -type d -print | LC_ALL=C sort >$dirs
myRead "filenames" && rdexec rfexec ucfirst
myRead "tags"      && rdexec rtag
myRead "lists"     && rdexec rlist

rm $dirs

exit 0
