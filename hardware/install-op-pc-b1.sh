# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-op-imscripts.sh
install-op-dafont.sh
install-op-firefox-abp.sh
install-op-firefox-cookies.sh
install-op-meteo.sh
install-op-ssh-server.sh
install-op-upgrades.sh
install-pr-bashrc.sh
install-pr-swap.sh
hardware/install-op-lp-ts5000.sh
hardware/install-op-ipod.sh
"

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
