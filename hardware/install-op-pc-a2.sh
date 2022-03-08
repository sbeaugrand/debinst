# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-pr-alias.sh
install-pr-bashrc.sh
install-pr-swap.sh
hardware/install-op-fix-suspend.sh
"

if notGrep cryptsetup /etc/sudoers; then
    cat >>/etc/sudoers <<EOF
$user ALL=(root) NOPASSWD:/sbin/modprobe dm-crypt
$user ALL=(root) NOPASSWD:/sbin/cryptsetup
$user ALL=(root) NOPASSWD:/usr/bin/dd
$user ALL=(root) NOPASSWD:/usr/bin/mount
$user ALL=(root) NOPASSWD:/usr/bin/umount
EOF
fi

file=/etc/X11/xorg.conf.d/99-mode.conf
if notFile $file; then
    cat >$file <<EOF
Section "Monitor"
  Identifier "LVDS"
  Option "PreferredMode" "1280x800"
  Option "Primary" "true"
EndSection

Section "Monitor"
  Identifier "VGA-0"
  Option "PreferredMode" "720x400"
  Option "RightOf" "LVDS"
EndSection
EOF
fi
