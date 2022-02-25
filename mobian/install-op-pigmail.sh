# ---------------------------------------------------------------------------- #
## \file install-op-pigmail.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
service=pigmail

file=/usr/lib/systemd/user/$service.service
if notFile $file; then
    cat >>$file <<EOF
[Unit]
Description=Python Imap Gtk Mail
Wants=graphical.target dbus.service network.target
After=graphical.target dbus.service network.target

[Service]
Environment=DISPLAY=:0
Environment=GTK_THEME=Adwaita:dark
WorkingDirectory=$idir/mobian/$service
ExecStart=$idir/mobian/$service/$service.py

[Install]
WantedBy=default.target
EOF
fi

file=$service/user-pr-config.py
if notFile $file; then
    cat <<EOF

Todo:

cp $service/user-ex-config.py $file
vi $file  # set imapHost and imapUser

EOF
    return 1
fi

imapHost=`grep 'imapHost =' $file | cut -d '=' -f 2`
imapUser=`grep 'imapUser =' $file | cut -d '=' -f 2`
cat <<EOF

Todo:

python3 -m keyring set $imapHost $imapUser
systemctl --user start $service

EOF

if ! sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 systemctl --user -q is-enabled $service; then
    sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 systemctl --user enable $service
fi
