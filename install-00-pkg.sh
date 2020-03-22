# ---------------------------------------------------------------------------- #
## \file install-00-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
listFile="simplecdd-op-1amd64/list.txt"
sta=`lsb_release -sc`

if [ "`dpkg --print-architecture`" = "amd64" ] &&
   [ "`dpkg --print-foreign-architectures`" != "i386" ]; then
    dpkg --add-architecture i386
fi

if grep "^deb cdrom" /etc/apt/sources.list; then
    sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
fi

export DEBIAN_FRONTEND=noninteractive

file=/etc/apt/sources.list.d/debian.list
if notFile $file; then
    cat >$file <<EOF
deb http://httpredir.debian.org/debian $sta main contrib non-free
deb http://httpredir.debian.org/debian/ $sta-updates main contrib non-free
deb-src http://httpredir.debian.org/debian $sta main contrib non-free
deb-src http://httpredir.debian.org/debian/ $sta-updates main contrib non-free

# backports
#  deb http://httpredir.debian.org/debian $sta-backports main contrib non-free
#  deb http://httpredir.debian.org/debian $sta-backports-sloppy main contrib non-free
#  ex: sudo apt -t $sta-backports install kicad
EOF
    if isOnline; then
        apt-get -q -y update >>$log
        apt-get -q -y dist-upgrade >>$log
    fi
fi

if isOnline; then
    list=`cat $listFile | sed 's/ *#.*//' | tr '\n' ' '`
    if [ `uname -m` != "x86_64" ]; then
        list=`echo $list | sed 's/libc6-i386//'`
    fi

    apt-get -q -y install --no-install-recommends $list >>$log
fi
