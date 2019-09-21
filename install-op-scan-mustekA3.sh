# ---------------------------------------------------------------------------- #
## \file install-op-scan-mustekA3.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# ftp://ftp.mustek.com.tw/pub/new/driver/0_Old%20Products/ScanExpress\
# %20A3%20USB%201200%20Pro/Linux/1LV1019/
# A3USB1200Pro-040B-20141209.zip
# libsane_1.0.19-1_i386.deb
# sane-backends-1.0.19-2.i386.rpm
# ---------------------------------------------------------------------------- #
if [ -e /usr/lib/i386-linux-gnu/libsane.so.1 ]; then
    apt-get remove libsane
fi

if notFile /usr/lib/sane/libsane-mustek_usb2.so.1.0.19; then
    pushd / || return 1
    ar p $home/install/config/libsane_1.0.19-1_i386.deb data.tar.gz | tar xz
    popd
fi

if notFile /usr/lib/i386-linux-gnu/libtiff.so.4; then
    ln -sf\
      /usr/lib/i386-linux-gnu/libtiff.so.5\
      /usr/lib/i386-linux-gnu/libtiff.so.4
fi

file=/etc/udev/rules.d/56-sane-backends-autoconfig.rules
if [ ! -f $file ]; then
    echo 'ATTR{idVendor}=="055f", ATTR{idProduct}=="040b", MODE="0666"' >$file
else
    if grep 055f $file | grep -q 040b; then
        return 0
    fi
    cp -a $file $file.bak
    cat $file.bak | tr '\n' '@' |\
 sed 's/AT/ATTR{idVendor}=="055f", ATTR{idProduct}=="040b", MODE="0666"@AT/' |\
 tr '@' '\n' >$file
fi
udevadm control --reload-rules
