# ---------------------------------------------------------------------------- #
## \file install-03-ntp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notGrep 'Europe/Paris' /etc/timezone; then
    cp /usr/share/zoneinfo/Europe/Paris /etc/localtime
    echo "Europe/Paris" >/etc/timezone
    /sbin/dpkg-reconfigure -f noninteractive tzdata >>$log
    sed -i 's/debian/fr/' /etc/ntp.conf
    systemctl stop ntp.service >>$log
    sntp -s fr.pool.ntp.org >>$log
    systemctl start ntp.service >>$log
fi
