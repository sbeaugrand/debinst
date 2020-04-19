# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-autologin.sh
install-op-dafont.sh
install-op-firefox-abp.sh
install-op-firefox-safesearch.sh
install-op-firefox-vdh.sh
install-op-firefox-vdhcoapp.sh
install-op-flashplayer.sh
install-op-meteo.sh
install-op-rpi-xc.sh
install-op-upgrades.sh
install-pr-alias.sh
install-pr-bashrc.sh
install-pr-swap.sh
install-op-skype.sh
install-op-ctparental.sh
hardware/install-op-fix-hd-apm.sh
hardware/install-op-lp-hpP1006.sh
hardware/install-op-scan-mustekA3.sh
"

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi
