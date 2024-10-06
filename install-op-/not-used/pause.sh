#!/bin/bash
hmax=${1:-17}
mmax=${2:-45}
cmd="DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY notify-send"
tmp=/tmp/crontab

crontab -l 2>/dev/null | grep -v '#pause' >$tmp

date +%H:%M | awk -F: '
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
