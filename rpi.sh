#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file rpi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
project=`basename $0 .sh`
if [ `whoami` = "root" ]; then
    echo "Usage: [user=pi] [host=rpi] ./$project.sh"
    exit 1
fi
user=${user:-pi}
host=${host:-rpi}
uri=$user@$host
echo "user = $user"
echo "host = $host"

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
file=$project/install-pr-authorized_keys
if ! isFile $file; then
    exit 1
fi
ssh $uri "test -d .ssh || mkdir .ssh && chmod 700 .ssh"
rsync -i --no-times --checksum --copy-links\
 $file $uri:/home/$user/.ssh/authorized_keys

# ---------------------------------------------------------------------------- #
# PasswordAuthentication=no
# ---------------------------------------------------------------------------- #
if ! ssh -o PasswordAuthentication=no $uri true; then
    exit 1
fi
ssh $uri "
grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config ||\
 sudo sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/'\
 /etc/ssh/sshd_config"

# ---------------------------------------------------------------------------- #
# install
# ---------------------------------------------------------------------------- #
ssh $uri "test -d install/debinst/latex || mkdir -p install/debinst/latex"
ssh $uri "test -d install/debinst/projects || mkdir install/debinst/projects"
rsync -rli --delete --no-times --checksum --exclude=build --exclude=*.pdf\
 --exclude=kicad --exclude=*.ko --exclude=*.dtbo\
 ~/install/debinst/0install.sh\
 ~/install/debinst/$project\
 ~/install/debinst/armbian\
 ~/install/debinst/bin\
 ~/install/debinst/makefiles\
 $uri:/home/$user/install/debinst/
rsync -rli --delete --no-times --checksum --exclude=build --exclude=*.pdf\
 --exclude=__pycache__\
 ~/install/debinst/latex/cal\
 ~/install/debinst/latex/makefiles\
 $uri:/home/$user/install/debinst/latex/
rsync -rli --delete --no-times --checksum --exclude=build --exclude=*.pdf\
 ~/install/debinst/projects/mp3server\
 ~/install/debinst/projects/debug\
 ~/install/debinst/projects/makefiles\
 ~/install/debinst/projects/wiki\
 $uri:/home/$user/install/debinst/projects/

# ---------------------------------------------------------------------------- #
# data
# ---------------------------------------------------------------------------- #
ssh $uri "test -d data/install-build || mkdir -p data/install-build"
ssh $uri "test -d data/install-repo || mkdir -p data/install-repo"

# ---------------------------------------------------------------------------- #
# passwd
# ---------------------------------------------------------------------------- #
ssh $uri "
test -f data/install-build/passwd ||
 (passwd && sudo passwd root && touch data/install-build/passwd)"

# ---------------------------------------------------------------------------- #
# rasp-config
# ---------------------------------------------------------------------------- #
#ssh $uri "
#test -f data/install-build/raspi-config ||
# (sudo raspi-config nonint do_expand_rootfs &&
# touch data/install-build/raspi-config)"
