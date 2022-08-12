#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file ipforward.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
netId=${3:-10.66.0}
mobianIpaddr=$netId.1
debianIpaddr=$netId.2

if [ -n "$1" ]; then
    debianIntf=$1
else
    debianIntf=`sed '1d' /proc/net/arp | awk '{ print $NF }' | tail -n 1`
    if [ -z "$debianIntf" ]; then
        echo "debian interface not found"
        exit 1
    fi
fi

if [ -n "$2" ]; then
    mobianIntf=$2
else
    mobianIntf=`sed '1d' /proc/net/dev | grep '^enx' | grep -v "$debianIntf" -m 1 | cut -d ':' -f 1`
    if [ -z "$mobianIntf" ]; then
        echo "mobian interface not found"
        exit 1
    fi
fi

echo "debianIntf = $debianIntf"
echo "mobianIntf = $mobianIntf"
if ip address | grep -q "$debianIpaddr"; then
    echo "$debianIpaddr already added"
else
    echo -n "ifconfig $mobianIntf ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        sudo ip address add $debianIpaddr dev $mobianIntf
        sudo ip route add $netId.0/24 dev $mobianIntf
    fi
fi

echo -n "ip forward ? (O/n) "
read ret
if [ "$ret" != n ]; then
    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
    sudo service nftables start
    sudo nft add table nat
    sudo nft add chain nat postrouting { type nat hook postrouting priority 0 \; }
    sudo nft add rule nat postrouting oifname $debianIntf counter masquerade
    sudo nft add table filter
    sudo nft add chain filter forward { type filter hook forward priority 0 \; }
    sudo nft add rule filter forward iifname $mobianIntf oifname $debianIntf counter accept
    sudo nft add rule filter forward iifname $debianIntf oifname $mobianIntf ct state related,established counter accept
    # sudo nft list ruleset
fi

if ! grep -q mobian /etc/hosts; then
    echo
    echo "Todo:"
    echo
    echo "sudo vi /etc/hosts +  # $mobianIpaddr mobian"
    echo "ssh mobian@mobian"
    echo "vi .bashrc +  # alias ipf='sudo ip route add default via $debianIpaddr'"
    echo
fi
