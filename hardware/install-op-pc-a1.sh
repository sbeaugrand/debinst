# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-/install-op-arduino.sh
install-op-/install-op-autologin.sh
install-op-/install-op-imscripts.sh
install-op-/install-op-dafont.sh
install-op-/install-op-eeplot.sh
install-op-/install-op-firefox-abp.sh
install-op-/install-op-firefox-safesearch.sh
install-op-/install-op-firefox-vdh.sh
install-op-/install-op-firefox-vdhcoapp.sh
install-op-/install-op-firefox-cookies.sh
install-op-/install-op-firefox-automute.sh
install-op-/install-op-fonts-cursive.sh
install-op-/install-op-fonts-morse.sh
install-op-/install-op-id3ed.sh
install-op-/install-op-kiplot.sh
install-op-/install-op-mp3gain.sh
install-op-/install-op-lingot.sh
install-op-/install-op-m4acut.sh
install-op-/install-op-meteo.sh
install-op-/install-op-mraa-xc.sh
install-op-/install-op-uncrustify.sh
install-op-/install-op-upgrades.sh
install-op-/install-op-ytdlp.sh
install-op-/install-op-avidemux.sh
install-op-/install-op-camotics.sh
install-pr-/install-pr-alias.sh
install-pr-/install-pr-bashrc.sh
install-pr-/install-pr-pdcroix.sh
install-op-/install-op-ssh-keygen.sh
hardware/install-op-hotspot.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-grbl-sim.sh
hardware/marlin/install-op-marlin-src.sh
-su
hardware/install-op-scan-mustekA3.sh
"

file=/etc/X11/xorg.conf.d/99-mode.conf
if notFile $file; then
    cat >$tmpf <<EOF
Section "Monitor"
  Identifier "`xrandr | grep -m 1 connected | cut -d ' ' -f 1`"
`gtf 1920 1080 60`
  Option "PreferredMode" "1920x1080_60.00"
EndSection
EOF
    sudoRoot cp $tmpf $file
fi

file=/etc/X11/xorg.conf.d/98-touchpad.conf
if notFile $file; then
    cat >$tmpf <<EOF
# grep "Using input driver" /var/log/Xorg.0.log
# xinput list
# xinput set-button-map "AlpsPS/2 ALPS DualPoint TouchPad" 1 0 3
Section "InputClass"
    Identifier "TouchPad"
    Driver "libinput"
    MatchProduct "AlpsPS/2 ALPS DualPoint TouchPad"
    Option "ButtonMapping" "1 0 3"
EndSection
EOF
    sudoRoot cp $tmpf $file
fi

file=$home/.Xresources
if notGrep 'xterm\*font: 9x15' $file; then
    sed -i 's/xterm\*font: .*/xterm\*font: 9x15/' $file
fi

file=$home/.config/lxsession/LXDE/autostart
if notGrep brightness $file; then
    if [ -z "$DISPLAY" ]; then
        logError "DISPLAY is not set"
        return 0
    fi
    output=`xrandr | grep -m 1 connected | cut -d ' ' -f 1`
    echo "@xrandr --output $output --brightness 0.55" >>$file
fi

if notLink $home/.gramps && isDir /data/gramps; then
    ln -s /data/gramps $home/.gramps
fi

if notWhich chromium; then
    sudoRoot apt-get install chromium
fi
