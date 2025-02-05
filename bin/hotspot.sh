#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file hotspot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note vi ~/install/debinst/bin/hotspot-pr-.sh
##       setup()
##       {
##           for ip in 10.66.0.39 10.66.0.16; do
##               addFilter $ip m.youtube
##               addFilter $ip www.youtube
##               addFilter $ip www.tiktok
##           done
##       }
##       loop()
##       {
##           addFilterAfter 30 10.66.0.39 game.brawlstarsgame.com "comment"
##       }
# ---------------------------------------------------------------------------- #
ipdns=10.66.0.2

# ---------------------------------------------------------------------------- #
## \fn quit
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
    for i in $wlp; do
        sudo nft delete rule filter FORWARD handle $i
    done

    if ((dnsdump)); then
        sudo systemctl stop tcpdump-dns
    elif ((tcpdump)); then
        kill -15 $tcpdump
    fi

    exit $1
}

# ---------------------------------------------------------------------------- #
## \fn hexDomain
# ---------------------------------------------------------------------------- #
hexDomain()
{
    domain=$1
    for s in `echo $domain | tr '.' ' '`; do
        echo -n $s | awk '{ printf "%02x",length() }'
        echo -n $s | hexdump -v -e '1/1 "%02x"'
    done
}

# ---------------------------------------------------------------------------- #
## \fn addFilter
# ---------------------------------------------------------------------------- #
addFilter()
{
    ip=$1
    dom=$2
    if sudo nft list ruleset 2>/dev/null | grep -q "saddr $ip .*\"$dom\""; then
        return
    fi
    hex=`hexDomain $dom`
    len=`echo $hex | awk '{ print length() * 4 }'`
    sudo nft add chain ip filter input { type filter hook input priority 0 \; }
    sudo nft add rule filter input ip saddr $ip meta l4proto udp udp dport 53 @th,160,$len 0x$hex counter drop comment $dom
}

# ---------------------------------------------------------------------------- #
## fn addFilterAfter
# ---------------------------------------------------------------------------- #
addFilterAfter()
{
    min=$1
    ip="$2"
    dom=$3
    com="$4"
    h=`sudo journalctl -u tcpdump-dns -S today | grep $dom | awk '
{
    h = int(substr($3, 1, 2));
    m = int(substr($3, 4, 2)) + '$min';
    if (m >= 60) {
        m -= 60;
        h += 1;
        if (h > 24) {
            exit 0;
        }
    }
    printf "%02d:%02d\n", h, m;
    exit 0;
}
'`
    if [ -z "$h" ]; then
        return
    fi
    if sudo nft list ruleset 2>/dev/null | grep -q "saddr $ip .*\"$com\""; then
        return
    fi
    sudo nft add chain ip filter input { type filter hook input priority 0 \; }
    sudo nft add rule filter input ip saddr $ip hour \> \"$h\" counter drop comment \"$com\"
}

# ---------------------------------------------------------------------------- #
# setup
# ---------------------------------------------------------------------------- #
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

if systemctl list-unit-files tcpdump-dns.service >/dev/null; then
    if ! systemctl -q is-active tcpdump-dns; then
        sudo systemctl start tcpdump-dns
    fi
    dnsdump=1
else
    if which tcpdump >/dev/null 2>&1; then
        file=/var/log/hotspot.pcap
        if [ -f $file ]; then
            sudo mv $file /var/log/hotspot.1.pcap
        fi
      sudo tcpdump -i $wlp -w $file -U "dst $ipdns and port 53" 2>/dev/null &
      tcpdump=$?
    fi
fi

file=${0%.*}-pr-.sh
if [ -f $file ]; then
    source $file
    if [ "`type -t setup`" = function ]; then
        setup
    fi
fi

trap "echo; quit 0" SIGINT

# ---------------------------------------------------------------------------- #
# loop
# ---------------------------------------------------------------------------- #
echo
echo "logs:"
echo "cat /var/log/dnscrypt-proxy/query.log"
if ((dnsdump)); then
    echo "sudo journalctl -u tcpdump-dns -S today"
elif ((tcpdump)); then
    echo "tcpdump -r /var/log/hotspot.pcap"
fi
echo "http://127.0.2.2/log.php"
echo "sudo journalctl -S-1d | grep ctpar"
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
    if [ "`type -t loop`" = function ]; then
        loop
    fi
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
