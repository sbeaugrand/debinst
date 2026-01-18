# ---------------------------------------------------------------------------- #
## \file hotspot-ex-.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
setup()
{
    whitelist="10.66.0.168, 10.66.0.67, 10.66.0.70, 10.66.0.39, 10.66.0.152, 10.66.0.170"
    for ip in 10.66.0.39 10.66.0.67; do
        addFilter $ip m.youtube
        addFilter $ip www.youtube
        addFilter $ip www.tiktok
    done
    if ((`date +%H%M | awk '{ print $0 + 1 }'` < 1730)); then
        if ! nft.sh list 2>/dev/null | grep -q "comment"; then
            nft.sh block 10.66.0.39 "comment"
            tmp=/tmp/crontab
            crontab -l 2>/dev/null >$tmp
            if ! grep -q "comment" $tmp; then
                echo '30 17 * * * /bin/bash PATH/nft.sh unblock "comment"' >>$tmp
                crontab $tmp
            fi
        fi
    fi
    if ! nft.sh list 2>/dev/null | grep -q "comment2"; then
        sudo nft add rule filter prerouting ip saddr 10.66.0.152 hour \> \"21:00\" counter drop comment \"comment2\"
    fi
}
loop()
{
    if ! nft.sh list 2>/dev/null | grep -q "Comment 20"; then
        addFilterAfter 20 10.66.0.39 "Alias  game.brawlstarsgame.com" "Comment 20"
    fi
}
