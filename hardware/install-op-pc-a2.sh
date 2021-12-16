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
