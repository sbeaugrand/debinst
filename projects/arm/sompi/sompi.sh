#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file sompi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# alias volet='sudo /home/$USER/install/debinst/projects/arm/sompi/sompi.sh'
# volet 0x123456 12345 register
# volet 0x123456 12346 close
# ---------------------------------------------------------------------------- #
if [ -z "$3" ]; then
    echo "Usage: `basename $0` <addr> <code> <open|close|stop|register>"
    echo "Ex:    $0 0x123456 12346 open"
    exit 1
fi
addr=$1
code=$2
action=$3

rdir=/run/remotes
rname=sompi
remote=$rdir/$rname.txt
user=`ls /home | tail -n 1`
sdir=/home/$user/install/debinst/projects/arm/sompi
log=/run/sompi.log

mkdir -p $rdir
echo $addr >$remote
echo $code >>$remote
touch $log

cd /run
PYTHONPATH=$sdir $sdir/SomPi/controller.py $rname $action >>$log
echo "next code : $((code + 1))"
