# ---------------------------------------------------------------------------- #
## \file hotspot-ex-.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
setup()
{
    whitelist="10.66.0.168, 10.66.0.66, 10.66.0.70, 10.66.0.39, 10.66.0.152"
    for ip in 10.66.0.39 10.66.0.66; do
        addFilter $ip m.youtube
        addFilter $ip www.youtube
        addFilter $ip www.tiktok
    done
    # sudo crontab -e
    # 00 18 * * * /bin/bash PATH/nft.sh unblock "comment"
    if ((`date +%H` < 18)); then
        if ! nft.sh list 2>/dev/null | grep -q "comment"; then
            nft.sh block 10.66.0.39 "comment"
        fi
    fi
}
loop()
{
    if ! nft.sh list 2>/dev/null | grep -q "Comment 20"; then
        addFilterAfter 21 10.66.0.39 "Alias  game.brawlstarsgame.com" "Comment 20"
    fi
}
