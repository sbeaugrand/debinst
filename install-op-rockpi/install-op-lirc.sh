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
if notFile $dir/$file; then
    copyFile $file $dir || return 1
fi
file=ir-nec-decoder.ko
if notFile $dir/$file; then
    copyFile $file $dir || return 1
fi
if notGrep "gpio-ir-recv" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
elif notGrep "ir-nec-decoder" /lib/modules/$(uname -r)/modules.dep; then
    /sbin/depmod
fi

file=/boot/armbianEnv.txt
if [ -f $file ]; then
    if notGrep rockpis-gpio-ir-recv $file; then
        /usr/sbin/armbian-add-overlay lirc/rockpis-gpio-ir-recv-low.dts
    fi
else
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
