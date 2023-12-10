#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file hotspot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
quit()
{
    if [ $1 = 0 ]; then
        nmcli con down hotspot
    fi
    /usr/sbin/rfkill block wifi
    if [ $1 = 1 ]; then
        exit 1
    fi

    enp=`sudo nft -a list chain filter FORWARD 2>/dev/null | grep 'iifname "enp' | awk '{ print $NF }'`
    wlp=`sudo nft -a list chain filter FORWARD 2>/dev/null | grep 'iifname "wlp' | awk '{ print $NF }'`
    if [ -n "$enp" ]; then
        sudo nft delete rule filter FORWARD handle $enp
    fi
    if [ -n "$wlp" ]; then
        sudo nft delete rule filter FORWARD handle $wlp
    fi

    exit $1
}

/usr/sbin/rfkill unblock wifi
sudo -k
sudo true || quit 1
nmcli con up hotspot || exit $?

if sudo nft list chain filter FORWARD 2>/dev/null | grep -q docker; then
    enp=`cat /proc/net/dev | cut -d ':' -f 1 | grep -m 1 '^enp'`
    wlp=`cat /proc/net/dev | cut -d ':' -f 1 | grep -m 1 '^wlp'`
    if [ -n "$enp" ] && [ -n "$wlp" ]; then
        if ! sudo nft list chain filter FORWARD 2>/dev/null | grep -q "$wlp"; then
            sudo nft add rule filter FORWARD iifname $wlp oifname $enp counter accept
            sudo nft add rule filter FORWARD iifname $enp oifname $wlp ct state related,established counter accept
        else
            echo "warn: rule already exists"
        fi
    else
        echo "warn: interface not found"
    fi
fi

trap "echo; quit 0" SIGINT
echo
echo -n "Ctrl-c pour fermer "

max=$1
if [ -z "$max" ]; then
    max=60
fi
count=0
while true; do
    sleep 600
    ((count++))
    if ((count == max)); then
        quit 0
    fi
    notify-send "wifi" "hotspot ouvert $count"
    sudo true
done
