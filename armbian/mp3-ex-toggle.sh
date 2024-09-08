#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3-ex-toggle.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dev=/dev/sda1
log=/var/log/mp3toggle.log

err()
{
    oledmesg -m "err $1" -x 0 -y 4 >>$log 2>&1
    exit 1
}

pid=`pgrep -o mp3-toggle.sh`
if ((pid != $$)); then
    kill -15 $pid
fi

if grep -q " /mnt/mp3 " /etc/mtab; then
    oledmesg -m "umount" -x 0 -y 5 >>$log 2>&1
    systemctl stop mp3server
    systemctl stop mpd

    umount /mnt/mp3 >>$log 2>&1 || err "umount"
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl start oscreensaver || err "oscreensaver"
    else
        oledmesg
    fi
else
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl stop oscreensaver
    fi

    mount $dev /mnt/mp3 >>$log 2>&1 || err "mount"
    systemctl start mpd       || err "mpd"
    systemctl start mp3server || err "service"
fi
