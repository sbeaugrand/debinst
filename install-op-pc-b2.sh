# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-op-dafont.sh
install-pr-bashrc.sh
install-pr-swap.sh
install-op-mplayer.sh
"

if notLink /etc/udev/rules.d/80-net-setup-link.rules; then
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
fi
