# ---------------------------------------------------------------------------- #
## \file install-30-readonly.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dns1=212.27.40.240
dns2=212.27.40.241

# /var/log
if notLink /var/log; then
    rm -fr /var/log
    ln -s /run/log /var/log
fi

file=/etc/systemd/journald.conf
if notGrep "Storage=volatile" $file; then
    sed -i 's/.*Storage=.*/Storage=volatile/' $file
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
file=/boot/boot.cmd
if notGrep " ro " $file; then
    sed -i 's/ rw / ro /' $file
fi

# fstab
file=/etc/fstab
if notGrep "defaults,ro" $file; then
    sed -i 's/defaults/defaults,ro/' $file
fi
