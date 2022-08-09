# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-arduino.sh
install-op-autologin.sh
install-op-imscripts.sh
install-op-eeplot.sh
install-op-fonts-morse.sh
install-op-id3ed.sh
install-op-kiplot.sh
install-op-mp3gain.sh
install-op-mraa-xc.sh
install-op-uncrustify.sh
install-op/install-op-avidemux.sh
install-op/install-op-camotics.sh
install-pr-alias.sh
install-pr-bashrc.sh
install-op-ssh-keygen.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-grbl-sim.sh
hardware/marlin/install-op-marlin-src.sh
-su
install-pr-swap.sh
hardware/install-op-alsa-order.sh
hardware/install-op-scan-mustekA3.sh
"

if notLink $home/.gramps && isDir /data/gramps; then
    ln -s /data/gramps $home/.gramps
fi
