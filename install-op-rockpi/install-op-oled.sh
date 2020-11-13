# ---------------------------------------------------------------------------- #
## \file install-op-oled.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/boot/armbianEnv.txt
if [ -f $file ]; then
    if notGrep "i2c1" $file; then
        if grep -q "^overlays" $file; then
            sed -i 's/\(overlays=.*\)/\1 i2c1/' $file || return 1
        else
            echo "overlays=i2c1" >>$file
        fi
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
    usermod -a -G i2c $user
fi
