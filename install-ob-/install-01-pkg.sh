# ---------------------------------------------------------------------------- #
## \file install-01-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
listFile="simplecdd-op-1amd64/list.txt"
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
deb http://httpredir.debian.org/debian $sta main contrib non-free
deb http://httpredir.debian.org/debian/ $sta-updates main contrib non-free
deb-src http://httpredir.debian.org/debian $sta main contrib non-free
deb-src http://httpredir.debian.org/debian/ $sta-updates main contrib non-free
EOF
    sudoRoot cp $tmpf $file
    if isOnline; then
        sudoRoot apt-get -q -y update
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
