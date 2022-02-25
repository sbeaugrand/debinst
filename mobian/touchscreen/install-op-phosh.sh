# ---------------------------------------------------------------------------- #
## \file install-op-phosh.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Workaround for damaged touchscreen on the bottom
# ---------------------------------------------------------------------------- #
gitClone https://gitlab.gnome.org/World/Phosh/phosh.git || return 1

dir=$bdir/phosh
if notGrep 'PHOSH_HOME_BUTTON_HEIGHT 120' $dir/src/home.h; then
    pushd $dir || return 1
    git apply $idir/mobian/install-op-phosh.patch
    popd
fi

if notFile /usr/local/bin/phosh; then
    pushd $dir || return 1
    apt-get -y build-dep .
    meson . build
    ninja -C build
    ninja -C build install
    popd
fi

dir=$home/.config/autostart
if notDir $dir; then
    mkdir $dir
fi

file=$dir/sm.puri.OSK0.desktop
if notFile $file; then
    cp /usr/share/applications/sm.puri.OSK0.desktop $file
fi

cat <<EOF
Todo:
sudo systemctl restart phosh
EOF
