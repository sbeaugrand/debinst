# ---------------------------------------------------------------------------- #
## \file install-op-lirc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
copyFile()
{
    file=$1
    dir=$2
    if ! isFile lirc/$file; then
        return 1
    fi
    if notFile $dir/$file; then
        cp lirc/$file $dir/
    fi
}

mkdir -p /lib/modules/$(uname -r)/kernel/drivers/media/rc
copyFile gpio-ir-recv.ko /lib/modules/$(uname -r)/kernel/drivers/media/rc || return 1
copyFile ir-nec-decoder.ko /lib/modules/$(uname -r)/kernel/drivers/media/rc || return 1
if notGrep "gpio-ir-recv" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
elif notGrep "ir-nec-decoder" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
fi

copyFile rockpis-gpio-ir-recv.dtbo /boot/dtbs/$(uname -r)/rockchip/overlay || return 1
file=/boot/uEnv.txt
if notGrep rockpis-gpio-ir-recv $file; then
    mount -o remount,rw /boot
    sed -i 's/\(overlays=.*\)/\1 rockpis-gpio-ir-recv/' $file || return 1
    mount -o remount,ro /boot
fi

copyFile joyit_nec.toml /lib/udev/rc_keymaps || return 1
copyFile joy-it-rc.service /usr/lib/systemd/system || return 1

file=/etc/lirc/irexec.lircrc
if notGrep "xmms2" $file; then
    cp lirc/$file /etc/lirc/
fi
