# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-/install-op-autologin.sh
install-op-/install-op-firefox-abp.sh
install-op-/install-op-firefox-vdh.sh
install-op-/install-op-firefox-vdhcoapp.sh
install-op-/install-op-firefox-cookies.sh
install-op-/install-op-firefox-automute.sh
install-op-/install-op-upgrades.sh
install-pr-/install-pr-bashrc.sh
install-op-/install-op-ssh-keygen.sh
install-op-/install-op-ssh-server.sh
-su
install-op-/install-op-mutt.sh
"

file=/etc/X11/xorg.conf.d/20-intel.conf
if notFile $file; then
    cat >$tmpf <<EOF
Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
EndSection
EOF
    sudoRoot cp $tmpf $file
fi

file=$home/.Xresources
if notGrep 'xterm\*font: 10x20' $file; then
    sed -i 's/xterm\*font: .*/xterm\*font: 10x20/' $file
fi
