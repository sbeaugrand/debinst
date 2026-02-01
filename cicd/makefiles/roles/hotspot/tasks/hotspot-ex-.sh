# ---------------------------------------------------------------------------- #
## \file hotspot-ex-.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
unblockAfter()
{
    hh=$1
    mm=$2
    ip=$3
    com="$4"
    if ((`date +%H%M | awk '{ print $0 + 1 }'` < $hh$mm)); then
        if ! nft.sh list 2>/dev/null | grep -q "$com"; then
            nft.sh block $ip "$com"
            tmp=/tmp/crontab
            crontab -l 2>/dev/null >$tmp
            if ! grep -q "$com" $tmp; then
                echo '$mm $hh * * * /bin/bash PATH/nft.sh unblock "$com"' >>$tmp
                crontab $tmp
            fi
        fi
    fi
}

setup()
{
    whitelist="10.66.0.168, 10.66.0.67, 10.66.0.70, 10.66.0.39, 10.66.0.152, 10.66.0.170, 10.66.0.113"
    for ip in 10.66.0.39 10.66.0.113 10.66.0.67; do
        addFilter $ip m.youtube
        addFilter $ip www.youtube
        addFilter $ip www.tiktok
    done
    unblockAfter 18 00 10.66.0.113 "enfant1"
    unblockAfter 18 00 10.66.0.39 "enfant2"
    if ! nft.sh list 2>/dev/null | grep -q "Enfant1 tablette"; then
        sudo nft add rule filter prerouting ip saddr 10.66.0.152 hour \> \"21:00\" counter drop comment \"Enfant1 tablette\"
    fi
}

loop()
{
    if ! nft.sh list 2>/dev/null | grep -q "Enfant1 40"; then
        addFilterAfter 40 10.66.0.113 "Enfant1 game.brawlstarsgame.com" "Enfant1 40"
    fi
    if ! nft.sh list 2>/dev/null | grep -q "Enfant2 20"; then
        addFilterAfter 20 10.66.0.39  "Enfant2 game.brawlstarsgame.com" "Enfant2 20"
    fi
}
