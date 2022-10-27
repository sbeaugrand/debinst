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

dir=/lib/modules/$(uname -r)/kernel/drivers/media/rc
mkdir -p $dir
file=gpio-ir-recv.ko
if notFile $dir/$file && notFile $dir/$file.xz; then
    copyFile $file $dir || return 1
fi
file=ir-nec-decoder.ko
if notFile $dir/$file && notFile $dir/$file.xz; then
    copyFile $file $dir || return 1
fi
if notGrep "gpio-ir-recv" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
elif notGrep "ir-nec-decoder" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
fi

file=/boot/armbianEnv.txt
if [ -f $file ]; then
    if notGrep gpio-ir-recv $file; then
        if [ `uname -n` = "orangepizero" ]; then
            /usr/sbin/armbian-add-overlay lirc/sun8i-h3-gpio-ir-recv.dts
        elif [ `uname -n` = "nanopineo" ]; then
            /usr/sbin/armbian-add-overlay lirc/nanopineo-gpio-ir-recv.dts
        elif [ `uname -n` = "rockpi-s" ]; then
            /usr/sbin/armbian-add-overlay lirc/rk3308-gpio-ir-recv.dts
        fi
        [ $? = 0 ] && logTodo "sudo reboot"
    fi
elif [ `uname -n` = "rockpi-s" ]; then
    file=/boot/uEnv.txt
    odir=/boot/dtbs/$(uname -r)/rockchip/overlay
    if notGrep rockpis-gpio-ir-recv $file; then
        mount -o remount,rw /boot
        copyFile rockpis-gpio-ir-recv.dtbo $odir || return 1
        sed -i 's/\(overlays=.*\)/\1 rockpis-gpio-ir-recv/' $file || return 1
        mount -o remount,ro /boot
    fi
fi

copyFile joyit_nec.toml /lib/udev/rc_keymaps || return 1
copyFile joy-it-rc.service /usr/lib/systemd/system || return 1
if ! systemctl -q is-enabled joy-it-rc 2>>$log; then
    systemctl enable joy-it-rc
fi
