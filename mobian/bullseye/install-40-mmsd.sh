# ---------------------------------------------------------------------------- #
## \file install-40-mmsd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
#MMSC=http://mms.free.fr
MMSC=http://212.27.40.225
APN=mmsfree
CON_NAME=FreeMMS
CON_USER=free
CON_PASS=free

# ---------------------------------------------------------------------------- #
# mmsd
# ---------------------------------------------------------------------------- #
dir=$home/.mms/modemmanager
if notDir $dir; then
    mkdir -p $dir
fi
file=$dir/mms
if notFile $file; then
    cat >>$file <<EOF
[Modem Manager]
CarrierMMSC=$MMSC
MMS_APN=$APN
CarrierMMSProxy=NULL
AutoProcessOnConnection=true
AutoProcessSMSWAP=false
EOF
fi

gitClone https://gitlab.com/kop316/mmsd.git || return 1

if notWhich mmsdtng; then
    pushd $bdir/mmsd || return 1
    meson build
    meson compile -C build
    meson install -C build
    popd
fi

file=/usr/lib/systemd/user/mmsd-tng.service
if notFile $file; then
    cat >>$file <<EOF
[Unit]
Description=Multimedia Messaging Service Daemon
After=ModemManager.service

[Service]
ExecStart=/usr/local/bin/mmsdtng -d

Restart=on-failure
RestartSec=10s

[Install]
WantedBy=default.target
EOF
fi

if ! sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 systemctl --user -q is-enabled mmsd-tng; then
    sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 systemctl --user enable mmsd-tng
fi
sudo -u $user DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 systemctl --user restart mmsd-tng

# ---------------------------------------------------------------------------- #
# purple-mm-sms
# ---------------------------------------------------------------------------- #
gitClone https://source.puri.sm/kop316/purple-mm-sms.git || return 1

if notFile /usr/lib/purple-2/mm-sms.so; then
    pushd $bdir/purple-mm-sms
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

# ---------------------------------------------------------------------------- #
# chatty
# ---------------------------------------------------------------------------- #
gitClone https://source.puri.sm/Librem5/chatty.git || return 1

if notFile /usr/local/bin/chatty; then
    pushd $bdir/chatty
    apt-get -y build-dep .
    meson build
    ninja -C build
    ninja -C build install
    popd
fi

# ---------------------------------------------------------------------------- #
# APN
# ---------------------------------------------------------------------------- #
if ! nmcli c show $CON_NAME >/dev/null 2>&1; then
    nmcli c add type gsm con-name $CON_NAME apn $APN gsm.home-only true gsm.username $CON_USER gsm.password $CON_PASS || return 1
    nmcli c up FreeMMS
else
    echo " warn: connection $CON_NAME already exists"
fi
