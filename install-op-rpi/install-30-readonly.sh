# ---------------------------------------------------------------------------- #
## \file install-30-readonly.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dns1=212.27.40.240
dns2=212.27.40.241

# swap
if isFile /var/swap; then
    apt-get -q -y remove dphys-swapfile >>$log
    apt-get -q -y autoremove >>$log
    rm -f /var/swap
fi

# /var/log
if notLink /var/log; then
    rm -fr /var/log
    ln -s /run/log /var/log
fi

# /var/spool/cron
if notLink /var/spool/cron; then
    rm -fr /var/spool/cron
    ln -s /run/cron /var/spool/cron
fi

# dns
if notGrep "nameserver $dns1" /etc/resolv.conf; then
    echo "nameserver $dns1" >/etc/resolv.conf
    echo "nameserver $dns2" >>/etc/resolv.conf
fi

# boot
file=/boot/cmdline.txt
if notGrep " ro " $file; then
    sed -i 's/rootwait/ro rootwait/' $file
fi

# fstab
file=/etc/fstab
if notGrep "noatime,ro" $file; then
    sed -i 's/noatime/noatime,ro/' $file
fi

# fake-hwclock
file=/etc/init.d/fake-hwclock
if notGrep "test" $file; then
    sed -i '
s@fake-hwclock l@test -e /etc/fake-hwclock.data \&\& fake-hwclock l@' $file
fi

file=/etc/cron.hourly/fake-hwclock
if notGrep "1970" $file; then
    sed -i '
s@fake-hwclock s@((`date +%Y` > 1970)) \&\& fake-hwclock s@' $file
fi
