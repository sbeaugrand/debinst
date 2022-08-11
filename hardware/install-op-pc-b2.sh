# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-/install-op-autologin.sh
install-op-/install-op-ssh-keygen.sh
"

if notLink /etc/udev/rules.d/80-net-setup-link.rules; then
    sudoRoot ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
fi
