#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file clks.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://gitlab.gnome.org/kailueke/wake-mobile
# ---------------------------------------------------------------------------- #
path=`dirname $0`

if [ "$1" = "off" ]; then
    if systemctl -q is-enabled system-wake-up.timer; then
        sudo systemctl disable system-wake-up.timer
    fi
    if systemctl -q is-active system-wake-up.timer; then
        sudo systemctl stop system-wake-up.timer
    fi
    if systemctl --user -q is-enabled wake-up.timer; then
        systemctl --user disable wake-up.timer
    fi
    if systemctl --user -q is-active wake-up.timer; then
        systemctl --user stop wake-up.timer
    fi
    exit 0
fi

# ---------------------------------------------------------------------------- #
# System Wake Up Timer
# ---------------------------------------------------------------------------- #
dir=/etc/systemd/system
sudo mkdir -p $dir/system-wake-up.timer.d

file=$dir/system-wake-up.timer.d/10-mobian.conf
echo "[Timer]" | sudo tee $file >/dev/null
gsettings get org.gnome.clocks alarms | sed 's/@[a-z{}]* //' |\
 sed -e 's/[<>]//g' -e "s/'/\"/g" | $path/clks.py | sudo tee -a $file

file=$dir/system-wake-up.timer
[ -f $file ] || sudo tee $file >/dev/null <<EOF
[Unit]
Description=System Wake Up Timer
[Timer]
Persistent=false
WakeSystem=true
AccuracySec=1us
OnCalendar=0000-01-01 00:00:00
[Install]
WantedBy=timers.target
EOF

# ---------------------------------------------------------------------------- #
# System Wake Up Action
# ---------------------------------------------------------------------------- #
file=$dir/system-wake-up.service
[ -f $file ] || sudo tee $file >/dev/null <<EOF
[Unit]
Description=System Wake Up Action
[Service]
ExecStart=/usr/bin/true
EOF

sudo systemctl daemon-reload
if ! systemctl -q is-enabled system-wake-up.timer; then
    sudo systemctl enable system-wake-up.timer
fi
sudo systemctl restart system-wake-up.timer

# ---------------------------------------------------------------------------- #
# User Wake Up Timer
# ---------------------------------------------------------------------------- #
dir=~/.config/systemd/user
mkdir -p $dir

file=$dir/wake-up.timer
cat >$file <<EOF
[Unit]
Description=User Wake Up Timer
[Install]
WantedBy=timers.target
[Timer]
Persistent=true
AccuracySec=1us
EOF
gsettings get org.gnome.clocks alarms | sed 's/@[a-z{}]* //' |\
 sed -e 's/[<>]//g' -e "s/'/\"/g" | $path/clks.py >>$file

# ---------------------------------------------------------------------------- #
# User Wake Up Action
# ---------------------------------------------------------------------------- #
file=~/.local/share/sounds/__custom/alarm-clock-elapsed.oga
if [ -f $file ]; then
    duration=`ffprobe -v error -show_entries format=duration\
     -of default=noprint_wrappers=1:nokey=1 $file |\
     awk '{ t=$0; if (t<60) { t=int(60/t)*t }; print int(t+1)+5 }'`
else
    duration=65
fi
echo "RuntimeMaxSec=$duration"

file=$dir/wake-up.service
cat >$file <<EOF
[Unit]
Description=User Wake Up Action
[Service]
ExecStartPre=/usr/bin/gnome-session-inhibit --inhibit suspend canberra-gtk-play -i message-new-instant
ExecStart=/usr/bin/gnome-session-inhibit --inhibit suspend gnome-clocks
RuntimeMaxSec=$duration
EOF

systemctl --user daemon-reload
if ! systemctl --user -q is-enabled wake-up.timer; then
    systemctl --user enable wake-up.timer
fi
systemctl --user restart wake-up.timer
