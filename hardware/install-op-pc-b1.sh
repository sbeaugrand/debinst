# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
hardware/install-op-rtl8821ce.sh
install-op-/install-op-autologin.sh
install-op-/install-op-imscripts.sh
install-op-/install-op-dafont.sh
install-op-/install-op-firefox-abp.sh
install-op-/install-op-firefox-cookies.sh
install-op-/install-op-firefox-automute.sh
install-op-/install-op-meteo.sh
install-op-/install-op-upgrades.sh
install-pr-/install-pr-bashrc.sh
install-op-/install-op-ssh-keygen.sh
install-op-/install-op-ssh-server.sh
hardware/install-op-lp-ts5000.sh
hardware/install-op-ipod.sh
"

if notLink $home/.gramps && isDir /data/gramps; then
    ln -s /data/gramps $home/.gramps
fi

file=$home/.config/lxsession/LXDE/autostart
if notGrep brightness $file; then
    if [ -z "$DISPLAY" ]; then
        logError "DISPLAY is not set"
        return 0
    fi
    output=`xrandr | grep -m 1 connected | cut -d ' ' -f 1`
    echo "@xrandr --output $output --brightness 0.75" >>$file
fi

file=$home/.bashrc
if notGrep hdmi $file; then
    echo "alias hdmi='xrandr --output eDP --mode 1600x900 --scale 1x1 --output HDMI-A-0 --same-as eDP --scale 0.9x1'" >>$file
fi

if notWhich chromium; then
    sudoRoot apt-get -q -y install --no-install-recommends chromium
fi
