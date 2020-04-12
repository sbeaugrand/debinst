#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file ssh-arietta.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    int1=$1
else
    int1=`sed '1d' /proc/net/arp | grep -v ' enp0' | awk '{ print $NF }' | head -1`
    if [ -z "$int1" ]; then
        int1="notfound"
    fi
fi

if [ -n "$2" ]; then
    int2=$2
else
    cat /proc/net/dev
    int2=`sed '1d' /proc/net/dev | grep '^enp0' | cut -d ':' -f 1 | head -1`
    if [ -z "$int2" ]; then
        echo "interface 2 not found"
        exit 1
    fi
fi

echo "int1 = $int1"
echo "int2 = $int2"
echo -n "ifconfig $int2 ? (O/n) "
read ret
if [ "$ret" != n ]; then
    sudo ip address add 192.168.10.20 dev $int2
    sudo /sbin/route add -net 192.168.10.0 netmask 255.255.255.0 dev $int2
fi

if [ "$int1" != "notfound" ]; then
    echo -n "ip forward ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
        sudo service nftables start
        sudo nft add table nat
        sudo nft add chain nat postrouting { type nat hook postrouting priority 0 \; }
        sudo nft add rule nat postrouting oifname $int1 counter masquerade
        sudo nft add table filter
        sudo nft add chain filter forward { type filter hook forward priority 0 \; }
        sudo nft add rule filter forward iifname $int2 oifname $int1 counter accept
        sudo nft add rule filter forward iifname $int1 oifname $int2 ct state related,established counter accept
    fi
fi

echo
echo "acmesystems:"
echo "ssh root@192.168.10.10"
echo

exit 0
