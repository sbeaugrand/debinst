# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
hardware/install-op-rtl8821ce.sh
install-op-autologin.sh
install-op-imscripts.sh
install-op-dafont.sh
install-op-firefox-abp.sh
install-op-firefox-cookies.sh
install-op-firefox-automute.sh
install-op-meteo.sh
install-op-ssh-server.sh
install-op-upgrades.sh
hardware/install-op-lp-ts5000.sh
hardware/install-op-ipod.sh
install-pr-bashrc.sh
install-pr-swap.sh
"

if notLink $home/.gramps && isDir $data/gramps; then
    ln -s $data/gramps $home/.gramps
fi

file=/etc/fstab
if grep -q 'mnt' $file; then
    sudo sed -i '/mnt/d' /etc/fstab
fi

file=$home/.bashrc
if notGrep hdmi $file; then
    echo "alias hdmi='xrandr --output eDP --mode 1600x900 --scale 1x1 --output HDMI-A-0 --same-as eDP --scale 0.9x1'" >>$file
fi

if notWhich chromium; then
    apt-get install chromium
fi
