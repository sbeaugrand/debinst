# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-/install-op-arduino.sh
install-op-/install-op-autologin.sh
install-op-/install-op-imscripts.sh
install-op-/install-op-eeplot.sh
install-op-/install-op-fonts-cursive.sh
install-op-/install-op-fonts-morse.sh
install-op-/install-op-fonts-gcodefonts.sh
install-op-/install-op-fstab.sh
install-op-/install-op-id3ed.sh
install-op-/install-op-mp3gain.sh
install-op-/install-op-avidemux.sh
install-op-/install-op-camotics.sh
install-pr-/install-pr-alias.sh
install-pr-/install-pr-bashrc.sh
install-op-/install-op-ssh-keygen.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-grbl-sim.sh
hardware/marlin/install-op-marlin-src.sh
-list=[\'uncrustify\'] install-op-/install-op-ansible.sh
-su
install-pr-/install-pr-swap.sh
hardware/install-op-alsa-order.sh
hardware/install-op-scan-mustekA3.sh
"

file=/etc/X11/xorg.conf.d/99-mode.conf
if notFile $file; then
    cat >$tmpf <<EOF
Section "Monitor"
  Identifier "`xrandr | grep -m 1 connected | cut -d ' ' -f 1`"
  DisplaySize 382 215
EndSection
EOF
    sudoRoot cp $tmpf $file
fi

if notLink $home/.gramps && isDir /data/gramps; then
    ln -s /data/gramps $home/.gramps
fi
