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

    if [ -n "$tcpdump" ]; then
        kill -15 $tcpdump
    fi

    exit $1
}

/usr/sbin/rfkill unblock wifi
sudo -k
sudo true || quit 1
nmcli con up hotspot || exit $?

enp=`cat /proc/net/dev | cut -d ':' -f 1 | grep -m 1 '^enp'`
wlp=`cat /proc/net/dev | cut -d ':' -f 1 | grep -m 1 '^wlp'`
if sudo nft list chain filter FORWARD 2>/dev/null | grep -q docker; then
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

if which tcpdump >/dev/null 2>&1; then
    sudo tcpdump -i $wlp -w /var/log/hotspot.pcap -U 'dst 10.66.0.2 and port 53' 2>/dev/null &
    tcpdump=$?
fi

trap "echo; quit 0" SIGINT
if [ -n "$tcpdump" ]; then
    echo
    echo "log: tcpdump -r /var/log/hotspot.pcap"
fi
echo
echo -n "Ctrl-c pour fermer "

interval=10
((sleep = interval * 60))
max=$1
if [ -z "$max" ]; then
    max=600
fi
minutes=0
id=0
while true; do
    sleep $sleep
    ((minutes = minutes + interval))
    if ((minutes == max)); then
        quit 0
    fi
    ((hh = minutes / 60))
    ((mm = minutes - hh * 60))
    if ((mm == 0)); then
        mm=00
    fi
    id=`notify-send -p -r $id "wifi" "hotspot ouvert ${hh}h$mm"`
    sudo true
done
