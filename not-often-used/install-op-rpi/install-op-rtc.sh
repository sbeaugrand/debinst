# ---------------------------------------------------------------------------- #
## \file install-op-rtc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=SunFounder_SensorKit_for_RPi2

gitClone https://github.com/sunfounder/$name.git || return 1

file=$bdir/$name/C/33_ds1302/rtc_ds1302.c

if notGrep "ds1302setup(14, 13, 12)" $file; then
    sed -i 's/ds1302setup *(0, 1, 2)/ds1302setup(14, 13, 12)/' $file
fi
if ! grep -q "ds1302setup(14, 13, 12)" $file; then
    echo " error: ds1302setup error"
    return 1
fi

if notGrep '%02d%02d"' $file; then
    sed -i 's/%02d%02d.%02d"/%02d%02d"/' $file
fi
if ! grep '%02d%02d"' $file; then
    echo " error: date format error"
    return 1
fi

file=/usr/bin/rtc
if notFile $file; then
    pushd $bdir/$name/C/33_ds1302 || return 1
    gcc -o $file rtc_ds1302.c -lwiringPi -lwiringPiDev >>$log 2>&1
    popd
fi

if isFile $file; then
    /usr/sbin/ntpdate -u ntp.u-psud.fr
    date +%Y%m%d%n%H%M%S%n%w | $file -sdsc
fi
