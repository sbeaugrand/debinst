# ---------------------------------------------------------------------------- #
## \file install-op-upgrades.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/cron.weekly/aptupgrade
if notFile $file; then
    cat >$tmpf <<EOF
#!/bin/sh
export DISPLAY=:0.0
export XAUTHORITY=$home/.Xauthority
xmessage Debut de mise a jour >/var/log/aptupgrade 2>&1 &
apt-get -y update >>/var/log/aptupgrade 2>&1
LANG=en apt list -qq --upgradeable | xmessage -file - &
sleep 5
apt-get -y dist-upgrade >>/var/log/aptupgrade 2>&1
apt-get -y autoremove >>/var/log/aptupgrade 2>&1
apt-get -y autoclean >>/var/log/aptupgrade 2>&1
xmessage Fin de mise a jour >>/var/log/aptupgrade 2>&1
EOF
    chmod 755 $tmpf
    sudoRoot cp $tmpf $file
    rm $tmpf
fi
