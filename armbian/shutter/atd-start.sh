#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file atd-start.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user=$1
hhmm=$2
echo $hhmm >/run/shutter.at
chown $user.$user /run/shutter.at

dir=/run/cron
file=$dir/atjobs/.SEQ
if [ ! -f $file ]; then
    mkdir -p $dir/atjobs
    mkdir -p $dir/atspool
    echo 0 >$file
    chown -R daemon.daemon $dir
    chmod -R 770 $dir
    systemctl start atd
fi
