#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-op-rpi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ `whoami` = "root" ] || [ -z "$RPI" ]; then
    echo "Usage: RPI=192.168.x.xx ./install-op-rpi.sh"
    echo "Ex:    RPI=192.168.0.16 ./install-op-rpi.sh"
    exit 1
fi

# ---------------------------------------------------------------------------- #
# isFile
# ---------------------------------------------------------------------------- #
isFile()
{
    if [ -f "$1" ]; then
        return 0
    else
        echo " error: $1 not found" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# notGrep
# ---------------------------------------------------------------------------- #
notGrep()
{
    if ! grep -q "$1" $2; then
        return 0
    else
        echo " warn: $1 already in $2" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# ssh
# ---------------------------------------------------------------------------- #
file=~/.profile
if isFile ~/.ssh/id_rsa.pub && notGrep "keychain" $file; then
    echo 'source ~/.keychain/*-sh' >>$file
fi
file=install-op-rpi/install-pr-authorized_keys
if ! isFile $file; then
    exit 1
fi
ssh pi@$RPI "test -d .ssh || mkdir .ssh && chmod 700 .ssh"
rsync -i --no-times --checksum $file pi@$RPI:/home/pi/.ssh/authorized_keys

# ---------------------------------------------------------------------------- #
# PasswordAuthentication=no
# ---------------------------------------------------------------------------- #
if ! ssh -o PasswordAuthentication=no pi@$RPI true; then
    exit 1
fi
ssh pi@$RPI "
grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config ||\
 sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/'\
 /etc/ssh/sshd_config"

# ---------------------------------------------------------------------------- #
# install
# ---------------------------------------------------------------------------- #
ssh pi@$RPI "test -d install/debinst || mkdir -p install/debinst"
rsync -rli --delete --no-times --checksum --exclude=build --exclude=*.pdf\
 ~/install/debinst/0install.sh\
 ~/install/debinst/install-op-rpi\
 ~/install/debinst/install-14-cal\
 ~/install/debinst/makefiles\
 pi@$RPI:/home/pi/install/debinst/

# ---------------------------------------------------------------------------- #
# data
# ---------------------------------------------------------------------------- #
ssh pi@$RPI "test -d data/install-build || mkdir -p data/install-build"
ssh pi@$RPI "test -d data/install-repo || mkdir -p data/install-repo"

# ---------------------------------------------------------------------------- #
# passwd
# ---------------------------------------------------------------------------- #
ssh pi@$RPI "
test -f data/install-build/passwd ||
 (passwd && sudo passwd root && touch data/install-build/passwd)"

# ---------------------------------------------------------------------------- #
# rasp-config
# ---------------------------------------------------------------------------- #
#ssh pi@$RPI "
#test -f data/install-build/raspi-config ||
# (sudo raspi-config nonint do_expand_rootfs &&
# touch data/install-build/raspi-config)"
