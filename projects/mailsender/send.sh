#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file send.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$4" ]; then
    duration=$4
else
    duration=15
fi
if [ -z "$3" ]; then
    echo "Usage: $0 <subject> <message> <list> [duration=$duration]"
    exit 1
fi
subject="$1"
message="$2"
list="$3"
log=~/mailsender.log

if [ ! -f ~/.muttrc ]; then
    echo ".muttrc not found"
    exit 1
fi

n=`cat $list | wc -l`
sleep=`echo $((3600*$duration/$n))`
cat /dev/null >$log

for ((i = 1; i <= n; i++)); do
    a=`cat $list | head -n $i | tail -1`
    echo $a >>$log
    /usr/bin/mutt -s "$subject" $a <"$message"
    ret=$?
    if [ $ret != 0 ]; then
        echo "`date +'%F %T'` $a"
    fi
    sleep $sleep
done
