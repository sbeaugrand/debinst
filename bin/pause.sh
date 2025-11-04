#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file pause.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
date=${1:-`date +%H:%M`}
hmax=${2:-17}
mmax=${3:-45}
cmd="DISPLAY=$DISPLAY\
 XAUTHORITY=$XAUTHORITY\
 XDG_RUNTIME_DIR=/run/user/1000\
 notify-send -t 0"
tmp=/tmp/crontab

crontab -l 2>/dev/null | grep -v '#pause' >$tmp

echo $date | awk -F: '
{
    h = $1 + 1;
    m = $2 + 0;
    while (h < '$hmax' ||
           m < '$mmax' && h == '$hmax') {
        if (h == 12) {
            h = 14;
            m = 0;
        }
        printf "%02d %02d * * * '"$cmd"' %02d:%02d #pause\n",m,h,h,m;
        ++h;
    }
}
' | cat >>$tmp

crontab $tmp
crontab -l | grep '#pause'
