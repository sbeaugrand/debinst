# ---------------------------------------------------------------------------- #
## \file install-op-oled.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/boot/armbianEnv.txt
if [ -f $file ]; then
    if [ `uname -n` = "rockpi-s" ]; then
        i2c="i2c1"
    else
        i2c="i2c0"
    fi
    if notGrep $i2c $file; then
        if grep -q "^overlays" $file; then
            sed -i "s/\(overlays=.*\)/\1 $i2c/" $file || return 1
        else
            echo "overlays=$i2c" >>$file
        fi
        logTodo "sudo reboot"
    fi
else
    file=/boot/uEnv.txt
    if notGrep "rk3308-i2c1" $file; then
        mount -o remount,rw /boot
        sed -i 's/\(overlays=.*\)/\1 rk3308-i2c1/' $file || return 1
        mount -o remount,ro /boot
    fi
fi

if ! groups $user | grep -q "i2c"; then
    /usr/sbin/usermod -a -G i2c $user
fi
