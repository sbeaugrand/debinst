# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-arduino.sh
install-op-autologin.sh
install-op-autowhite.sh
install-op-dafont.sh
install-op-eeplot.sh
install-op-firefox-abp.sh
install-op-firefox-safesearch.sh
install-op-firefox-vdh.sh
install-op-firefox-vdhcoapp.sh
install-op-flashplayer.sh
install-op-id3ed.sh
install-op-kiplot.sh
install-op-m4acut.sh
install-op-meteo.sh
install-op-rpi-xc.sh
install-op-uncrustify.sh
install-op-upgrades.sh
install-pr-alias.sh
install-pr-bashrc.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-scan-mustekA3.sh
"

file=$home/.config/lxsession/LXDE/autostart
if notGrep brightness $file; then
    if [ -z "$DISPLAY" ]; then
        echo " warn: DISPLAY is not set" | tee -a $log
        return 0
    fi
    output=`xrandr | grep -m 1 connected | cut -d ' ' -f 1`
    echo "@xrandr --output $output --brightness 0.55" >>$file
fi

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
