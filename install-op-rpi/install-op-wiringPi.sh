# ---------------------------------------------------------------------------- #
## \file install-op-wiringPi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
#repo=$idir/../wiringPi
#untar wiringPi.tgz ||\
# gitClone git://git.drogon.net/wiringPi || return 1
repo=$idir/../WiringPi
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone git://github.com/WiringPi/WiringPi.git || return 1

export PATH=$PATH:/sbin

if notFile /usr/local/include/wiringPi.h; then
    pushd $bdir/wiringPi/wiringPi || return 1
    if [ `uname -m` = "x86_64" ]; then
        make >>$log 2>&1 CC=arm-linux-gnueabihf-gcc V=1
        make >>$log 2>&1 CC=arm-linux-gnueabihf-gcc V=1 install
    else
        make >>$log 2>&1
        make >>$log 2>&1 install
    fi
    popd
fi

if notLink /usr/lib/libwiringPiDev.so; then
    pushd $bdir/wiringPi/devLib || return 1
    if [ `uname -m` = "x86_64" ]; then
        make >>$log 2>&1 CC=arm-linux-gnueabihf-gcc V=1 INCLUDE=-I/usr/local/include
        make >>$log 2>&1 CC=arm-linux-gnueabihf-gcc V=1 install
    else
        make >>$log 2>&1
        make >>$log 2>&1 install
    fi
    popd
fi
