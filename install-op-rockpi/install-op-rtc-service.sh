# ---------------------------------------------------------------------------- #
## \file install-op-rtc-service.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
isFile /usr/bin/rtc || return 1

pushd ../projects/arm/ds1302 || return 1
make -f service.mk install || return 1
make -f service.mk start || return 1
popd

systemctl disable ntp.service
