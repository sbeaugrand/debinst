# ---------------------------------------------------------------------------- #
## \file install-04-fstab.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
for f in b1 b2 b3 b4 c1 c2 c3 c4 m1 m2 m3 m4; do
    if notDir /mnt/$f; then
        mkdir /mnt/$f
    fi
    if notGrep /mnt/$f /etc/fstab; then
        if [ ${f:0:1} = m ]; then
            i=${f:1:1}
            echo "/dev/mmcblk0p$i /mnt/$f auto users,noauto 0 0" >>/etc/fstab
        else
            echo "/dev/sd$f /mnt/$f auto users,noauto 0 0" >>/etc/fstab
        fi
    fi
done
