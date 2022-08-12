#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file minuteur.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
audiofile=libreoffice/share/gallery/sounds/pluck.wav
audiotime=1

if [ -f /usr/lib64/$audiofile ]; then
    audiofile=/usr/lib64/$audiofile
elif [ -f /usr/lib/$audiofile ]; then
    audiofile=/usr/lib/$audiofile
else
    audiofile=
fi

chrono()
{
    echo -n "0 "
    for ((i = 1; i <= 1; ++i)); do
        sleep 1
        tput cub 4
        echo -n "$i "
    done
    echo
}

chrono $(($1 - audiotime))
if [ -n "$audiofile" ]; then
    aplay $audiofile 2>/dev/null &
fi
sleep $audiotime
tput hpa 0
tput cuu1
echo "$i "
