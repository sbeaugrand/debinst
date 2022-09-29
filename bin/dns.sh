#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file dns.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dns1=127.0.2.1
dns2=80.67.169.12,80.67.169.40  # https://www.fdn.fr/actions/dns/

connection=`nmcli -g name,type con show | grep -m 1 ethernet | cut -d ':' -f 1`
if [ -z "$connection" ]; then
    echo "error: ethernet connection not found"
    exit 1
fi

if [ -z "$1" ]; then
    dns=$dns1
    if nmcli con show "$connection" | grep "ipv4.dns:" | grep -q "$dns"; then
        dns=$dns2
    fi
else
    dns=$1
    if nmcli con show "$connection" | grep "ipv4.dns:" | grep -q "$dns"; then
        exit 0
    fi
fi

sudo nmcli con mod "$connection" ipv4.dns "$dns"\
 ipv4.ignore-auto-dns yes\
 ipv6.ignore-auto-dns yes || exit 1
nmcli con down "$connection" && nmcli con up "$connection"
echo "dns=$dns"
