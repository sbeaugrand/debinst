# ---------------------------------------------------------------------------- #
## \file install-75-notifications.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$XDG_DATA_HOME/dbus-1/services
if notDir $dir; then
    mkdir -p $dir
fi

file=$dir/org.freedesktop.Notifications.service
if notFile $file; then
    cat >$file <<EOF
# BEGIN ANSIBLE MANAGED BLOCK
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/lib/notification-daemon/notification-daemon
# END ANSIBLE MANAGED BLOCK
EOF
fi
