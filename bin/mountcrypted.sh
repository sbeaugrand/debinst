#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mountcrypted.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
clear="\033[1A\033[K"

# ---------------------------------------------------------------------------- #
# options
# ---------------------------------------------------------------------------- #
if [ "$1" = "-h" ]; then
    echo "Usage:  `basename $0` [-u] [-n] [partition] [point de montage]"
    exit 0
fi
if [ "$1" = "-u" ]; then
    shift
    usbkey=1
fi
if [ "$1" = "-n" ]; then
    shift
    skipconn=1
fi

# ---------------------------------------------------------------------------- #
# connexion
# ---------------------------------------------------------------------------- #
if [ "$skipconn" != 1 ]; then
    conn=`nmcli -t -f device connection show --active`
    if [ -n "$conn" ]; then
        echo "erreur: connexion active ($conn)"
        exit 1
    fi
fi

# ---------------------------------------------------------------------------- #
# securekbd
# ---------------------------------------------------------------------------- #
if which xvkbd >/dev/null 2>&1; then
    securekbd()
    {
        if [ "$usbkey" != 1 ]; then
            xvkbd -text "\[F9] \b" >/dev/null 2>&1
        fi
    }
else
    securekbd()
    {
        true
    }
    echo "todo: sudo apt-get install xvkbd"
fi

# ---------------------------------------------------------------------------- #
# module
# ---------------------------------------------------------------------------- #
if ! lsmod | grep -q dm_crypt; then
    sudo /sbin/modprobe dm-crypt
fi

# ---------------------------------------------------------------------------- #
# device
# ---------------------------------------------------------------------------- #
device()
{
    if [ ! -b $1 ]; then
        return 1
    fi
    if grep -q "^$1 " /etc/mtab; then
        echo "$1 est deja ouvert"
        return 1
    fi
    if sudo /sbin/cryptsetup status crypted | grep -q $1 || \
       sudo /sbin/cryptsetup status backup  | grep -q $1; then
        echo "$1 est deja ouvert"
        return 1
    fi
    dev=$1
    return 0
}

if [ -n "$1" ]; then
    device $1
fi
if [ -z "$dev" ]; then
    device /dev/sdb1 || \
    device /dev/sdc1 || \
    device /dev/sdd1 || \
    device /dev/sde1
fi
if [ -z "$dev" ]; then
    echo "aucun peripherique"
    exit 1
fi
echo "dev=$dev"

# ---------------------------------------------------------------------------- #
# media
# ---------------------------------------------------------------------------- #
media()
{
    if grep -q " $1 " /etc/mtab; then
        echo "$1 est indisponible"
        return 1
    fi
    dir=$1
    crypted="crypted`echo $dir | tr '/' '-'`"
    return 0
}

if [ -n "$2" ]; then
    media ${2%%/}
fi
if [ -z "$dir" ]; then
    media /mnt/crypted || \
    media /mnt/backup  || (echo "aucun media disponible" && exit 1)
fi
if [ ! -d $dir ]; then
    sudo mkdir -p $dir
fi
echo "dir=$dir"
echo "map=$crypted"

# ---------------------------------------------------------------------------- #
# usbkey
# ---------------------------------------------------------------------------- #
if [ "$usbkey" = 1 ]; then
    while [ ! -b /dev/usbkey ]; do
        sleep 1
    done
    sudo /usr/bin/dd if=/dev/usbkey bs=512 skip=4 count=8 | \
        sudo /sbin/cryptsetup luksOpen --key-file - $dev $crypted
    if [ $? != 0 ]; then
        echo "exit ou Ctrl-d pour sortir"
        bash
        exit 1
    fi
fi

# ---------------------------------------------------------------------------- #
# montage
# ---------------------------------------------------------------------------- #
if [ ! -e /dev/mapper/$crypted ]; then
    if sudo /sbin/cryptsetup isLuks $dev; then
        cmd="sudo /sbin/cryptsetup luksOpen $dev $crypted"
    else
        echo -n "key size ? [128] "
        read keysize
        echo -e "${clear}key size ? [128] "
        if [ -z "$keysize" ]; then
            keysize=128
        fi
        cmd="sudo /sbin/cryptsetup -s \$keysize open --type plain $dev $crypted"
    fi
    echo $cmd
    securekbd
    if ! eval $cmd; then
        securekbd
        echo "exit ou Ctrl-d pour sortir"
        bash
        exit 1
    else
        securekbd
    fi
fi
if ! sudo /usr/bin/mount /dev/mapper/$crypted $dir; then
    echo "exit ou Ctrl-d pour sortir"
    bash
    sudo /sbin/cryptsetup close $crypted
    exit 1
fi

# ---------------------------------------------------------------------------- #
# bash
# ---------------------------------------------------------------------------- #
cd $dir
if [ -f ./bashrc ]; then
    bash --rcfile ./bashrc
else
    ls -l --color
    echo "exit ou Ctrl-d pour sortir"
    bash
fi

# ---------------------------------------------------------------------------- #
# demontage
# ---------------------------------------------------------------------------- #
cd
if [ -f $dir/bash_logout ]; then
    source $dir/bash_logout
fi
while ! sudo /usr/bin/umount $dir; do
    if ! grep -q "/dev/mapper/$crypted" /etc/mtab; then
        break;
    fi
    bash --norc
done
sudo /sbin/cryptsetup close $crypted
if [ $USER = root ]; then
    rm -f ~/.emacs-last ~/.emacs-places
fi
