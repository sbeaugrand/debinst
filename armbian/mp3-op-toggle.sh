#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3-op-toggle.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
user=rock
dev=/dev/sda1
log=/var/log/mp3toggle.log

err()
{
    oled-message "err $1" 0 4 >>$log 2>&1
    exit 1
}

if grep -q " /mnt/mp3 " /etc/mtab; then
    oled-message "umount" 0 5 >>$log 2>&1
    systemctl stop mp3server.service >>$log 2>&1
    sudo -u $user XMMS_PATH=unix:///run/xmms-ipc-ip\
     /usr/bin/xmms2 server shutdown >>$log 2>&1

    umount /mnt/mp3 >>$log 2>&1 || err "umount"
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl start oscreensaver >>$log 2>&1
    else
        oled-message
    fi
else
    if [ -x /usr/bin/oscreensaver ]; then
        systemctl stop oscreensaver >>$log 2>&1
    fi

    mount $dev /mnt/mp3 >>$log 2>&1 || err "mount"
    systemctl start mp3server.service >>$log 2>&1 || err "service"
fi
