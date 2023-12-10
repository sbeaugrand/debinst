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

ipv4dns()
{
    dns=$1
    sudo nmcli con mod "$connection" ipv4.dns "$dns"\
         ipv4.ignore-auto-dns yes\
         ipv6.ignore-auto-dns yes || exit 1
    nmcli con down "$connection" && nmcli con up "$connection"
    echo "dns=$dns"
}

quit()
{
    ipv4dns $dns1
    exit $1
}

sudo -k
sudo true || quit 1
ipv4dns $dns2

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
    notify-send "dns" "$count"
    sudo true
done
