# ---------------------------------------------------------------------------- #
## \file install-30-readonly.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
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
