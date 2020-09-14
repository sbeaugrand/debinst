# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-arduino.sh
install-op-autologin.sh
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

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
