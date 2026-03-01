# ---------------------------------------------------------------------------- #
## \file brightness.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
percent="$1"
if [ -z "$percent" ]; then
    vendor=`cat /sys/devices/virtual/dmi/id/board_vendor`
    if [ "$vendor" = "Dell Inc." ]; then
        percent=55
    elif [ "$vendor" = "ASUSTeK COMPUTER INC." ]; then
        percent=75
    else
        echo "Usage: `basename $0` [<percent>]"
        exit 1
    fi
fi

output=`grep -m1 " Output .* connected$" /var/log/Xorg.0.log |
 cut -d'O' -f2 |
 cut -d' ' -f2`

xrandr --output $output --brightness 0.$percent
