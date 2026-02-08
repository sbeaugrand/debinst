# ---------------------------------------------------------------------------- #
## \file hotspot-ex-.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
nftsh=$HOME/install/debinst/bin/nft.sh

ipE1a=10.66.0.113
ipE1b=10.66.0.152
ipE2a=10.66.0.39
ipE2b=10.66.0.170
ipE3a=10.66.0.67
ipE3b=10.66.0.70

setup()
{
    whitelist="$ipE1a, $ipE1b, $ipE2a, $ipE2b, $ipE3a, $ipE3b, 10.66.0.168"
    for ip in $ipE1a $ipE2a $ipE3a; do
        block $ip m.youtube
        block $ip www.youtube
        block $ip www.tiktok
    done
    unblockAfter 18 00 $ipE1a "enfant1"
    unblockAfter 18 00 $ipE2a "enfant2"
    if ! nft.sh list 2>/dev/null | grep -q "Enfant1 tablette"; then
        nft.sh block $ipE1b "Enfant1 tablette" 21:00
    fi
}

loop()
{
    blockAfter 40 $ipE1a "Enfant1 game.brawlstarsgame.com" "Enfant1 40"
    blockAfter 20 $ipE2a "Enfant2 game.brawlstarsgame.com" "Enfant2 20"
}
