# ---------------------------------------------------------------------------- #
## \file nft.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` [dry] <command> [<argument>]..."
    echo "Ex:    nft.sh block 10.66.0.11"
    echo "       nft.sh block 10.66.0.11 \"a comment\""
    echo "       nft.sh block 10.66.0.11 \"a comment\" 12:12"
    echo "       nft.sh list | grep \"a comment\""
    echo "       nft.sh unblock 44"
    echo "       nft.sh unblock \"a comment\""
    echo "       nft.sh log [-f]"
    exit 1
fi

if [ "$1" = "dry" ]; then
    nft="echo sudo nft"
    shift
else
    nft="sudo /sbin/nft"
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
    if [ -z "${2//[0-9]}" ]; then
        handle=$2
    else
        handle=`$0 list 2>/dev/null | grep "$2" | awk '{ print $NF }'`
    fi
    if ((handle)); then
        $nft delete rule filter input handle $handle
    else
        echo "handle not found"
    fi
elif [ $action = "log" ]; then
    shift
    sudo journalctl -u tcpdump-dns -S today $*
elif [ $action = "ping" ]; then
    ip=$2
    ping -4 -c 1 -W 0.1 $ip | awk -F '[()]' '{ print $2; exit 0 }'
fi
