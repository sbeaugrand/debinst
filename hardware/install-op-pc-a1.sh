# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-arduino.sh
install-op-autologin.sh
install-op-imscripts.sh
install-op-dafont.sh
install-op-eeplot.sh
install-op-firefox-abp.sh
install-op-firefox-safesearch.sh
install-op-firefox-vdh.sh
install-op-firefox-vdhcoapp.sh
install-op-firefox-cookies.sh
install-op-firefox-automute.sh
install-op-id3ed.sh
install-op-kiplot.sh
install-op-lingot.sh
install-op-m4acut.sh
install-op-meteo.sh
install-op-mraa-xc.sh
install-op-uncrustify.sh
install-op-upgrades.sh
install-pr-alias.sh
install-pr-bashrc.sh
install-pr-pdcroix.sh
install-op-ssh-keygen.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-scan-mustekA3.sh
"

file=$home/.Xresources
if notGrep 'xterm\*font: 9x15' $file; then
    sed -i 's/xterm\*font: .*/xterm\*font: 9x15/' $file
fi

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

if notWhich chromium; then
    apt-get install chromium
fi
