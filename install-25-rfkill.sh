# ---------------------------------------------------------------------------- #
## \file install-25-rfkill.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxsession/LXDE/autostart

if notGrep rfkill $file; then
    echo "@/usr/sbin/rfkill block wlan" >>$file
fi

if /usr/sbin/rfkill -o TYPE,SOFT | grep unblocked | grep -q wlan; then
    /usr/sbin/rfkill block wlan
fi
