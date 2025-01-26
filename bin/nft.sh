# ---------------------------------------------------------------------------- #
## \file nft.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` [dry] <action> [options]..."
    echo "Ex:    nft.sh block 10.66.0.11"
    echo "       nft.sh block 10.66.0.11 \"a comment\""
    echo "       nft.sh block 10.66.0.11 \"a comment\" 12:12"
    echo "       nft.sh list | grep 'a comment'"
    echo "       nft.sh unblock 44"
    exit 1
fi

if [ "$1" = "dry" ]; then
    nft="echo sudo nft"
    shift
else
    nft="sudo nft"
fi
action=$1

if [ $action = "list" ]; then
    $nft -a list ruleset
elif [ $action = "block" ]; then
    ip=$2
    if [ -n "$3" ]; then
        comment=" comment \"$3\""
    fi
    if [ -n "$4" ]; then
        hour=" hour > \"$4\""
    fi
    $nft add chain ip filter input { type filter hook input priority 0 \; }
    $nft add rule filter input ip saddr $ip$hour counter drop$comment
elif [ $action = "unblock" ]; then
    handle=$2
    $nft delete rule filter input handle $handle
elif [ $action = "ping" ]; then
    ip=$2
    ping -4 -c 1 -W 0.1 $ip | awk -F '[()]' '{ print $2; exit 0 }'
fi
