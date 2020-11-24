# ---------------------------------------------------------------------------- #
## \file install-op-rtc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/usr/bin/rtc
if notFile $file; then
    pushd $idir/projects/arm/ds1302 || return 1
    make >>$log 2>&1 HOME=$home
    make >>$log 2>&1 HOME=$home reinstall
    popd
fi

isFile $file || return 1

/usr/sbin/ntpdate -u ntp.u-psud.fr
ldconfig /usr/local/lib
$file `date +%FT%Tw%w`

if ! systemctl -q is-enabled rtc; then
    pushd ../projects/arm/ds1302 || return 1
    make >>$log 2>&1 install || return 1
    make >>$log 2>&1 start || return 1
    popd
fi

if systemctl -q is-enabled ntp; then
    systemctl disable ntp.service
fi
