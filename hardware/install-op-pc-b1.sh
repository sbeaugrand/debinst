# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-op-dafont.sh
install-op-firefox-abp.sh
install-op-flashplayer.sh
install-op-meteo.sh
install-op-upgrades.sh
install-pr-bashrc.sh
install-pr-swap.sh
hardware/install-op-lp-ts50000.sh
hardware/install-op-ipod.sh
"

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
