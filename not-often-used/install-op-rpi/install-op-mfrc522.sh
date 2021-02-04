# ---------------------------------------------------------------------------- #
## \file install-op-mfrc522.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
return 1

if notDir $data/tmp/rpi-rc522; then
    pushd $data/tmp || return 1
    svn checkout http://rpi-rc522.googlecode.com/svn/trunk/ rpi-rc522
    popd
fi

if notFile $data/tmp/rpi-rc522/rc522/rc522_reader; then
    pushd $data/tmp/rpi-rc522/rc522 || return 1
    gcc config.c rfid.c rc522.c main.c -o rc522_reader -lbcm2835
    cp RC522.conf /etc/
    #./rc522_reader -d
    popd
fi

if notDir $data/tmp/SPI-Py; then
    pushd $data/tmp || return 1
    git clone https://github.com/lthiery/SPI-Py.git
    popd
fi

#pushd $data/tmp/SPI-Py || return 1
#python setup.py install
#popd

if notFile $data/tmp/MFRC522-python/Read.py; then
    pushd $data/tmp || return 1
    git clone https://github.com/mxgxw/MFRC522-python.git
    #vi /boot/config.txt +/spi
    #sudo reboot
    #cd MFRC522-python
    #sudo python Read.py
    popd
fi
