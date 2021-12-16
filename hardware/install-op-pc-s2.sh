# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-op-firefox-abp.sh
install-op-firefox-vdh.sh
install-op-firefox-vdhcoapp.sh
install-op-firefox-cookies.sh
install-op-firefox-automute.sh
install-op-upgrades.sh
install-pr-bashrc.sh
install-op-ssh-keygen.sh
install-op-mutt.sh
"

file=/etc/X11/xorg.conf.d/20-intel.conf
if notFile $file; then
    cat >$file <<EOF
Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
EndSection
EOF
fi

file=$home/.Xresources
if notGrep 'xterm\*font: 10x20' $file; then
    sed -i 's/xterm\*font: .*/xterm\*font: 10x20/' $file
fi

if notGrep mutt /etc/sudoers; then
    cat >>/etc/sudoers <<EOF
$user ALL=(mutt) ALL
mutt ALL=(root) ALL
EOF
fi
