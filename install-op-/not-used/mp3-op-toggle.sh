#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3-op-toggle.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dev=/dev/sda1
log=/var/log/mp3toggle.log

err()
{
    oled-message "err $1" 0 4 >>$log 2>&1
    exit 1
}

pid=`pgrep -o mp3-toggle.sh`
if ((pid != $$)); then
    kill -15 $pid
fi

if grep -q " /mnt/mp3 " /etc/mtab; then
    oled-message "umount" 0 5 >>$log 2>&1
    systemctl stop mp3server
    systemctl stop mpd

    umount /mnt/mp3 >>$log 2>&1 || err "umount"
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl start oscreensaver || err "oscreensaver"
    else
        oled-message
    fi
else
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl stop oscreensaver
    fi

    mount $dev /mnt/mp3 >>$log 2>&1 || err "mount"
    systemctl start mpd       || err "mpd"
    systemctl start mp3server || err "service"
fi
