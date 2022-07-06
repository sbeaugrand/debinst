#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file shutter.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pos=$1
user=`ls /home | tail -n 1`

rollingCode()
{
    ref=/home/$user/data/install-build/shutter.txt
    new=/run/shutter.txt
    secs=`date +%s`
    sref=`stat -c%Y $ref`
    code=`tail -n 1 $ref`
    ((day1 = (secs) - (secs % 86400) ))
    ((day2 = (sref) - (sref % 86400) ))
    ((days = (day1 - day2) / 86400))
    ((code = (code) + days * 2))
    ((hour = (secs % 86400) / 3600))
    if ((hour > 12)); then
        ((code++))
    fi
}

if [ $pos = "none" ]; then
    rollingCode
    echo $code
    exit 0
fi

rollingCode
head -n 1 $ref >$new
echo $code >>$new

cd /home/$user/install/debinst/projects/arm/sompi
make $pos
