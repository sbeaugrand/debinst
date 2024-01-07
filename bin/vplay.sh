#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file vplay.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Alternatives
##       \ls --zero *.avi | xargs -I {} -0 mplayer -geometry +1280+0 -fs {}
##       \ls *.avi | xargs -I {} -d '\n' mplayer -geometry +1280+0 -fs {}
# ---------------------------------------------------------------------------- #
mplayer="mplayer -geometry +1280+0 -fs"
while [ -n "$1" ]; do
    if echo "$1" | grep -q '\.'; then
        break
    fi
    if [ -n "$opts" ]; then
        opts="$opts $1"
    else
        opts="$1"
    fi
    shift
done

if [ -z "$1" ]; then
    echo "Usage: `basename $0` [options] <filename> [1|2]"
    echo "       `basename $0` [options] <filename>..."
    exit 1
fi
file="$1"
if echo "$2" | grep -q '\.'; then
    while [ -n "$1" ]; do
        $mplayer $opt "$1"
        shift
    done
    exit $?
fi
part=${2:-3}

nbsec=`ffprobe -v fatal -show_entries format=duration\
 -of default=noprint_wrappers=1:nokey=1 "$file" | awk '{ print int($1) }'`
if [ $part = 1 ] || [ $part = 2 ]; then
    nbsec=$((nbsec / 2))
fi
hh=$((nbsec / 3600))
mm=$(((nbsec - hh * 3600) / 60))
echo
echo "Duree ${hh}h`echo $mm | awk '{ printf "%02d",$1 }'`"
echo
date -d "+${hh}hour +${mm}min" +"Fin %H:%M"
echo

if [ $part = 1 ]; then
    nbframes=$((nbsec * 25))
    $mplayer -frames $nbframes $opts "$file"
elif [ $part = 2 ]; then
    $mplayer -ss $nbsec $opts "$file"
else
    $mplayer $opts "$file"
fi
