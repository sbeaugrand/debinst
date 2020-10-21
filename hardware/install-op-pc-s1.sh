# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-arduino.sh
install-op-autologin.sh
install-op-autowhite.sh
install-op-eeplot.sh
install-op-emacs-php.sh
install-op-fonts-morse.sh
install-op-id3ed.sh
install-op-kiplot.sh
install-op-mp3gain.sh
install-op-rpi-xc.sh
install-op-rockpi-xc.sh
install-op-sdcc.sh
install-op-uncrustify.sh
install-pr-bashrc.sh
install-pr-swap.sh
hardware/install-op-alsa-order.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-scan-mustekA3.sh
"

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
