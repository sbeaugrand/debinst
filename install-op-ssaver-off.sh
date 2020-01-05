# ---------------------------------------------------------------------------- #
## \file install-op-ssaver-off.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$DISPLAY" ]; then
    echo " warn: DISPLAY is not set" | tee -a $log
    return 0
fi

file=$home/.xscreensaver
if notGrep "mode:..off" $file; then
    sed -i 's/^mode:.*/mode:\t\toff/' $file
fi

if pgrep xscreensaver >/dev/null; then
    xscreensaver-command -exit
fi

file=/etc/xdg/lxsession/LXDE/autostart
if grep -q "xscreensaver" $file; then
    sed -i '/xscreensaver/d' $file
else
    echo " warn: xscreensaver not found in $file" | tee -a $log
fi
