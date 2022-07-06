#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file shutter-and-at.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ((`date +%H | awk '{ print $1 + 0 }'` > 12)); then
    pos=close
else
    pos=open
fi

if [ -d /boot/grub ]; then
    user=`ls /home | tail -n 1`
    sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 notify-send ./shutter.sh $pos
else
    ./shutter.sh $pos
fi

./shutter-at.sh
