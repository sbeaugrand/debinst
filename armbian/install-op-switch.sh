# ---------------------------------------------------------------------------- #
## \file install-op-switch.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/lirc/irexec.lircrc
if notGrep "switch" $file; then
    touch $file
    cat >>$file <<EOF
begin
    prog   = irexec
    button = KEY_1
    config = $home/install/debinst/projects/arm/rc-switch/rc-pr-switch.sh 1
end
begin
    prog   = irexec
    button = KEY_2
    config = $home/install/debinst/projects/arm/rc-switch/rc-pr-switch.sh 2
end
begin
    prog   = irexec
    button = KEY_3
    config = $home/install/debinst/projects/arm/rc-switch/rc-pr-switch.sh 3
end
EOF
fi

if ! systemctl -q is-enabled irexec 2>>$log; then
    systemctl enable irexec
fi
