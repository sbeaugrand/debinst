#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file rectangle.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
lang=fr

if [ -r structure.txt ]; then
    grep "aid" structure.txt
    aid=`grep "aid" structure.txt | grep -m 1 $lang`
    aid=${aid:0-4:3}
    if [ -z "$aid" ]; then
        aid=`grep -m 1 "aid" structure.txt`
        aid=${aid:0-4:3}
    fi
    # Case for the zero value
    aid=`echo "$aid" | cut -d " " -f 2`
    aid="-aid $aid"
fi

mplayer -msglevel vfilter=3 -vf rectangle=720:432:0:72 -nosub $aid $*
