# ---------------------------------------------------------------------------- #
## \file install-01-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
listFile="simplecdd-op-1arch64/list.txt"
sta=`lsb_release -sc`

if [ "`dpkg --print-architecture`" = "amd64" ] &&
   [ "`dpkg --print-foreign-architectures`" != "i386" ]; then
    sudoRoot dpkg --add-architecture i386
fi

if grep "^deb cdrom" /etc/apt/sources.list; then
    sudoRoot sed -i "'s/^deb cdrom/#deb cdrom/'" /etc/apt/sources.list
fi

export DEBIAN_FRONTEND=noninteractive

file=/etc/apt/sources.list.d/debian.list
if notFile $file; then
    cat >$tmpf <<EOF
# BEGIN ANSIBLE MANAGED BLOCK
deb http://httpredir.debian.org/debian $sta main contrib non-free-firmware
deb http://httpredir.debian.org/debian/ $sta-updates main contrib non-free-firmware
deb-src http://httpredir.debian.org/debian $sta main contrib non-free-firmware
deb-src http://httpredir.debian.org/debian/ $sta-updates main contrib non-free-firmware
# END ANSIBLE MANAGED BLOCK
EOF
    sudoRoot cp $tmpf $file
    if grep -q "hypervisor" /proc/cpuinfo; then
        return 0
    fi
    if isOnline; then
        logInfo "apt-get update ..."
        sudoRoot apt-get -q -y update
        logInfo "apt-get dist-upgrade ..."
        sudoRoot apt-get -q -y dist-upgrade
    fi
fi

if isOnline; then
    list=`cat $listFile | sed 's/ *#.*//' | tr '\n' ' '`
    if [ `uname -m` != "x86_64" ]; then
        list=`echo $list | sed 's/libc6-i386//'`
    fi

    sudoRoot apt-get -q -y install --no-install-recommends $list
fi

pyver=`python3 -c '
import sys
print("{}.{}".format(sys.version_info.major, sys.version_info.minor))'`

file=/usr/lib/python$pyver/EXTERNALLY-MANAGED
if isFile $file; then
    sudoRoot mv $file $file.bak
fi
