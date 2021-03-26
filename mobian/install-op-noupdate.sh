# ---------------------------------------------------------------------------- #
## \file install-op-noupdate.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if systemctl -q is-enabled apt-daily-upgrade.timer; then
    systemctl disable apt-daily-upgrade.timer
fi

if systemctl -q is-enabled apt-daily.timer; then
    systemctl disable apt-daily.timer
fi

if systemctl -q is-enabled packagekit; then
    systemctl stop packagekit
    systemctl mask packagekit
    dpkg-divert --divert /etc/PackageKit/20packagekit.distrib --rename  /etc/apt/apt.conf.d/20packagekit
fi
