#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file disk.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dev=/dev/cdrom
mnt=/media/cdrom

# ---------------------------------------------------------------------------- #
# Usage
# ---------------------------------------------------------------------------- #
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    name=`basename $0`
    echo "Lecture  :  $name "
    echo "Ecriture :  $name <iso|repertoire>"
    exit 0
fi

# ---------------------------------------------------------------------------- #
# User
# ---------------------------------------------------------------------------- #
if [ `whoami` != "root" ]; then
    su -c "$0 $*"
    exit $?
fi

# ---------------------------------------------------------------------------- #
# Media
# ---------------------------------------------------------------------------- #
if [ ! -d $mnt ]; then
    mkdir $mnt
fi
if  grep "$mnt" /etc/mtab >/dev/null; then
    echo "$mnt n'est pas utilisable"
    exit 1
fi

# ---------------------------------------------------------------------------- #
# Lecture
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo -n "dechiffrer ? (o/N) "
    read ret
    if [ "$ret" = o ]; then
        modprobe dm-crypt
        loop=`losetup -f`
        losetup $loop $dev
        cryptsetup -v -c aes-cbc-plain -h sha512 create crypted $loop
        if [ $? != 0 ]; then
            losetup -d $loop
            exit 1
        fi
        mount -t iso9660 /dev/mapper/crypted $mnt
        echo "todo:"
        echo "umount $mnt"
        echo "cryptsetup remove crypted"
        echo "losetup -d $loop"
    else
        mount -t iso9660 $dev $mnt
    fi
    exit 0
fi

# ---------------------------------------------------------------------------- #
# wodim
# ---------------------------------------------------------------------------- #
which wodim >/dev/null 2>&1 || \
(echo -n "installation de wodim: " && zypper install wodim)

# ---------------------------------------------------------------------------- #
# Ecriture
# ---------------------------------------------------------------------------- #
dir=${1%%/}
if [ "${dir:0-4:4}" = ".iso" ]; then
    iso="$dir"
    echo "iso=$iso"
    overwrite=n
else
    iso="$dir.iso"
    echo "iso=$iso"
    overwrite=o
    if [ -f "$iso" ]; then
        echo -n "ecraser $iso ? (o/N) "
        read overwrite
        if [ -z "$overwrite" ]; then
            overwrite=n
        fi
    fi
    if [ $overwrite = o ] || [ ! -f "$iso" ]; then
        echo -n "chiffrer ? (o/N) "
        read crypt
        if [ "$crypt" = o ]; then
            which aespipe >/dev/null 2>&1 ||\
                (echo -n "installation de aespipe: " &&\
                 zypper install aespipe)
            genisoimage -f -J -l -R -V "$dir" "$dir" |\
                aespipe -e AES256 -T >"$iso"
        else
            genisoimage -f -J -l -R -V "$dir" "$dir" >"$iso"
        fi
    fi
fi
wodim -prcap dev=$dev | grep "Write speed"
echo -n "vitesse ?x "
read speed
size=`stat -c%s "$iso"`
echo "taille du fichier iso : $size"
echo -n "graver ? (O/n) "
read ret
if [ "$ret" != n ]; then
    echo -n "vider le disque ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        wodim -v dev=$dev speed=$speed blank=fast -force
    fi
    wodim -v -dao -eject dev=$dev speed=$speed "$iso"
fi

# ---------------------------------------------------------------------------- #
# Verification
# ---------------------------------------------------------------------------- #
echo -n "verifier ? (O/n) "
read ret
if [ "$ret" != n ]; then
    echo -ne " (1) md5sum\n (2) diff\n [1] "
    read ret
    if [ -z "$ret" ] || [ $ret = 1 ]; then
        if [ ! -f "$iso.md5" ]; then
            echo -n "creer $iso.md5 ? (O/n) "
            read ret
            if [ "$ret" != n ]; then
                md5sum "$iso" >"$iso.md5"
            fi
        fi
        bs=`isoinfo -d -i $dev | grep "^Logical block size" | cut -d ' ' -f 5`
        if [ -z "$bs" ]; then
            echo "error: blank block size"
            exit 1
        fi
        echo "bs = $bs"
        bc=`isoinfo -d -i $dev | grep "^Volume size" | cut -d ' ' -f 4`
        if [ -z "$bc" ]; then
            bc=0
        fi
        fsz=`stat -c "%s" "$iso"`
        ((fbc = fsz / bs))
        if ((fbc > bc)); then
            bc=$fbc
        fi
        echo "bc = $bc"
        ((sz = bc * bs))
        if ((sz != fsz)); then
            echo "warning: data size = $sz"
            echo "warning: file size = $fsz"
        fi
        dd if=$dev bs=$bs count=$bc conv=notrunc,noerror \
            2>/tmp/disk.log | md5sum | cut -d ' ' -f 1 >md5sum.tmp
        cat md5sum.tmp
        if [ -f "$iso.md5" ]; then
            if cat "$iso.md5" | cut -d ' ' -f 1 | diff - md5sum.tmp; then
                echo "OK"
            else
                echo "KO"
            fi
        fi
        rm md5sum.tmp
    else
        if [ ! -d /mnt/removable ]; then
            mkdir /mnt/removable
        fi
        if  grep "/mnt/removable" /etc/mtab >/dev/null; then
            echo "/mnt/removable n'est pas utilisable"
            exit 1
        fi
        if [ $overwrite = n ]; then
            echo -n "dechiffrer ? (o/N) "
            read crypt
        fi
        if [ "$crypt" = o ]; then
            modprobe dm-crypt
            loop1=`losetup -f`
            losetup $loop1 "$iso"
            cryptsetup -v -c aes-cbc-plain -h sha512 create crypted1 $loop1
            if [ $? != 0 ]; then
                losetup -d $loop1
                exit 1
            fi
            loop2=`losetup -f`
            losetup $loop2 $dev
            cryptsetup -v -c aes-cbc-plain -h sha512 create crypted2 $loop2
            if [ $? != 0 ]; then
                cryptsetup remove crypted1
                losetup -d $loop1
                losetup -d $loop2
                exit 1
            fi
            mount -t iso9660 /dev/mapper/crypted1 /mnt/removable
            mount -t iso9660 /dev/mapper/crypted2 $mnt

            diff -rq /mnt/removable $mnt

            umount /mnt/removable
            umount $mnt
            cryptsetup remove crypted1
            cryptsetup remove crypted2
            losetup -d $loop1
            losetup -d $loop2
        else
            mount -t iso9660 -o loop "$iso" /mnt/removable
            mount -t iso9660 $dev $mnt
            cd /mnt/removable
            find . -type f -exec cmp {} $mnt/{} \;
            umount /mnt/removable
            umount $mnt
        fi
    fi
fi

exit 0
