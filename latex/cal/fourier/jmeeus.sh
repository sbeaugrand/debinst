#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file jmeeus.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
lat=$1
lon=$2
year=$3
s=$4
nyear=$5

printYear()
{
    yyyy=$1
    n=`echo $yyyy | awk '{ if ($1 % 4 == 0) print 366; else print 365 }'`
    for ((i = 0; i < n; ++i)); do
        mm=`date -d "$yyyy-01-01 +$i days" +%m`
        dd=`date -d "$yyyy-01-01 +$i days" +%d`
        echo -n "$j "
        ../build/sun $lat $lon $yyyy-$mm-$dd -4 $s | awk -F ' |:' '
{
    print $1 * 60 + $2 + $3 / 60;
}
'
    ((++j))
    done
}

j=1
for ((k = 0; k < $nyear; ++k)); do
    printYear `echo $year+$k | bc`
done
