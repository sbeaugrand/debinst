#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file cadran.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
y=$1
lat=$2
lon=$3
len=$4
dec=$5
ang=$6
file=$7
hour=`echo $file | sed 's@[a-z/.]*@@g' | sed 's@_@.@'`
if [ ${file:6:3} = "hiv" ]; then
    jBegin=21
    mBegin=12
    jEnd=21
    mEnd=3
elif [ ${file:6:3} = "pri" ]; then
    jBegin=21
    mBegin=3
    jEnd=21
    mEnd=6
elif [ ${file:6:3} = "ete" ]; then
    jBegin=21
    mBegin=6
    jEnd=21
    mEnd=9
else
    jBegin=21
    mBegin=9
    jEnd=21
    mEnd=12
fi
cat /dev/null >$file
for ((m = mBegin; m != mEnd + 1; ++m)); do
    if ((m > 12)); then
        m=1
    fi
    if [ $m = $mBegin ]; then
        jMin=$jBegin
    else
        jMin=1
    fi
    if [ $m = $mEnd ]; then
        jMax=$jEnd
    else
        case $m in
            1) jMax=31 ;;
            2) jMax=28 ;;
            3) jMax=31 ;;
            4) jMax=30 ;;
            5) jMax=31 ;;
            6) jMax=30 ;;
            7) jMax=31 ;;
            8) jMax=31 ;;
            9) jMax=30 ;;
            10) jMax=31 ;;
            11) jMax=30 ;;
            12) jMax=31 ;;
        esac
    fi
    for ((j = jMin; j <= jMax; ++j)); do
        build/cadran $y-$m-$j $lat $lon $hour $len $dec $ang >>$file 2>/dev/null
    done
done
