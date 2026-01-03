# ---------------------------------------------------------------------------- #
# pc
# ---------------------------------------------------------------------------- #
sourceList "
install-op-/install-op-autologin.sh
install-op-/install-op-imscripts.sh
install-op-/install-op-dafont.sh
install-op-/install-op-firefox-abp.sh
install-op-/install-op-firefox-cookies.sh
install-op-/install-op-firefox-automute.sh
install-op-/install-op-ssh-keygen.sh
install-op-/install-op-ssh-server.sh
hardware/install-op-lp-ts5000.sh
hardware/install-op-ipod.sh
-list=upgrade install-op-/install-op-ansible.sh
"

if notLink $home/.gramps && isDir /data/gramps; then
    ln -s /data/gramps $home/.gramps
fi

file=$home/.bash_aliases
if notGrep hdmi $file; then
    echo "alias hdmi='xrandr --output eDP --mode 1600x900 --scale 1x1 --output HDMI-A-0 --same-as eDP --scale 0.9x1'" >>$file
fi

if notWhich chromium; then
    sudoRoot apt-get -q -y install --no-install-recommends chromium  # webext-ublock-origin-chromium
fi
logTodo "chromium https://chromewebstore.google.com/search/ublock-origin-lite"
