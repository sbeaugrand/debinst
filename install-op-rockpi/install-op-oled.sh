# ---------------------------------------------------------------------------- #
## \file install-op-oled.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/boot/uEnv.txt
if notGrep rk3308-i2c1 $file; then
    mount -o remount,rw /boot
    sed -i 's/\(overlays=.*\)/\1 rk3308-i2c1/' $file || return 1
    mount -o remount,ro /boot
fi

if ! groups $user | grep -q "i2c"; then
    usermod -a -G i2c $user
fi
