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
    echo "       nft.sh replace \"a comment\"" 21:00
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
    $nft add chain ip filter prerouting { type filter hook prerouting priority 0 \; }
    $nft add rule filter prerouting ip saddr $ip$hour counter drop$comment
elif [ $action = "unblock" ]; then
    if [ -z "${2//[0-9]}" ]; then
        handle=$2
    else
        handle=`$0 list 2>/dev/null | grep -m 1 "$2" | awk '{ print $NF }'`
    fi
    if ((handle)); then
        if $nft -a list chain filter input 2>/dev/null | grep -q "handle $handle$"; then
            $nft delete rule filter input handle $handle
        elif $nft -a list chain filter prerouting 2>/dev/null | grep -q "handle $handle$"; then
            $nft delete rule filter prerouting handle $handle
        elif $nft -a list chain filter FORWARD 2>/dev/null | grep -q "handle $handle$"; then
            $nft delete rule filter FORWARD handle $handle
        fi
    else
        echo "handle not found"
    fi
elif [ $action = "replace" ]; then
    com="$2"
    handle=`$0 list 2>/dev/null | grep -m 1 "$com" | awk '{ print $NF }'`
    if ((handle)); then
        hour=$3
        ip=`$0 list 2>/dev/null | grep -m 1 "$com" | awk '{ print $3 }'`
        $nft replace rule filter prerouting handle $handle ip saddr $ip meta hour \> \"$hour\" counter drop comment \"$com\"
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
