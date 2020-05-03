#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mpg2mp3.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
convert()
{
    ext=$1
    max=`ls -1 *.$ext 2>/dev/null | wc -l`
    for ((i = 1; i <= max; i++)); do
        src=`ls -1 *.$ext | head -n $i | tail -1`
        wav=`basename "$src" .$ext`.wav
        mp3=`basename "$src" .$ext`.mp3
        ffmpeg -i "$src" -vcodec null -acodec pcm_s16le "$wav" &&\
        lame -q 0 -b 192 --cbr "$wav" "$mp3" &&\
        rm "$wav"
    done
}
convert MPG
convert mkv
convert webm
