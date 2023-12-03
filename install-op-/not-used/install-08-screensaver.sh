# ---------------------------------------------------------------------------- #
## \file install-08-screensaver.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
disableScreenSaver()
{
    if grep -q "xscreensaver" $1; then
        sudoRoot sed -i "'/xscreensaver/d'" $1
    else
        logWarn "xscreensaver not found in $1"
    fi
}

file=$home/.xscreensaver
if grep -q "hypervisor" /proc/cpuinfo; then
    cat >$file <<EOF
mode: off
EOF
    disableScreenSaver /etc/xdg/lxsession/LXDE/autostart
    disableScreenSaver $home/.config/lxsession/LXDE/autostart
else
    cat >$file <<EOF
mode: one
selected: 21
EOF
fi
