#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mpg2m4a.sh
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
        m4a=${src/%.$ext/.m4a}
        ffmpeg -i "$src" -vn -acodec copy "$m4a"
    done
}
convert mp4
