# ---------------------------------------------------------------------------- #
## \file install-op-rtc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/usr/sbin/rtc
if notFile $file; then
    pushd $idir/projects/arm/ds1302 || return 1
    make >>$log 2>&1 HOME=$home
    make >>$log 2>&1 HOME=$home reinstall
    popd
fi
isFile $file || return 1

/usr/sbin/ntpdate -u ntp.u-psud.fr
$file `date +%FT%Tw%w`
logTodo "update rtc clock during time changes"

if ! systemctl -q is-enabled rtc 2>>$log; then
    pushd ../projects/arm/ds1302 || return 1
    make >>$log 2>&1 HOME=$home install || return 1
    make >>$log 2>&1 HOME=$home start || return 1
    popd
fi

if systemctl -q is-enabled ntp; then
    systemctl disable ntp.service
fi
