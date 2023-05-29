#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file hotspot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
quit()
{
    nmcli con down hotspot
    sleep 1
    /usr/sbin/rfkill block wifi
    exit $1
}

sudo -k true || exit 1
/usr/sbin/rfkill unblock wifi
sleep 1
nmcli con up hotspot

trap "echo; quit 0" SIGINT
echo
echo -n "Ctrl-c pour fermer "

while true; do
    sleep 900
    notify-send "wifi" "hotspot ouvert"
done
