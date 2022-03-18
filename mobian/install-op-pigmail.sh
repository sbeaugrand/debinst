# ---------------------------------------------------------------------------- #
## \file install-op-pigmail.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
project=pigmail

file=$home/.local/share/applications/pigmail.desktop
if notFile $file; then
    cat >$file <<EOF
[Desktop Entry]
Name=Pigmail
Comment=Python Imap Gtk Mail
Icon=$home/.local/share/icons/pigmail.svg
Exec=env GTK_THEME=Adwaita:dark $idir/mobian/pigmail/pigmail.py
Type=Application
Terminal=false
Categories=Network;
Path=$idir/mobian/pigmail
EOF
fi

dir=$home/.local/share/icons
if notDir $dir; then
    mkdir -p $dir
fi
file=$dir/pigmail.svg
if notFile $file; then
    $idir/mobian/pigmail/icon.py $file
fi

if [ `uname -m` = "x86_64" ]; then
    dir=$XDG_DATA_HOME/dbus-1/services
    if notDir $dir; then
        mkdir -p $dir
    fi
    file=$dir/org.freedesktop.Notifications.service
    if notFile $file; then
        cat >$file <<EOF
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/lib/notification-daemon/notification-daemon
EOF
    fi
fi

file=$project/user-pr-config.py
if notFile $file; then
    cat <<EOF

Todo:

cp $project/user-ex-config.py $file
vi $file  # set imapHost and imapUser

EOF
    return 1
fi

imapHost=`grep 'imapHost =' $file | cut -d '=' -f 2`
imapUser=`grep 'imapUser =' $file | cut -d '=' -f 2`
cat <<EOF

Todo:

python3 -m keyring set $imapHost $imapUser

EOF
