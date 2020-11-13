# ---------------------------------------------------------------------------- #
## \file install-20-rtc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/sbin/rtc
if notFile $file; then
    pushd $idir/projects/arm/ds1302 || return 1
    make HOME=$home >>$log 2>&1
    make HOME=$home >>$log 2>&1 install
    popd
fi

if isFile $file; then
    /usr/sbin/ntpdate -u ntp.u-psud.fr
    ldconfig /usr/local/lib
    $file `date +%FT%Tw%w`
fi
