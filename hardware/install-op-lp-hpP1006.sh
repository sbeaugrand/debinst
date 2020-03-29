# ---------------------------------------------------------------------------- #
## \file install-op-lp-hpP1006.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cat <<EOF

Todo:

sudo apt install hplip
hp-setup -i -a -x -pHP_LaserJet_P1006
lpoptions -d HP_LaserJet_P1006

EOF
return 0

# debian jessie
if notFile /etc/cups/ppd/HP-LaserJet-P1006.ppd; then
    pushd $bdir || return 1
    tar xzf $home/install/config/imprimanteP1006/foo2zjs.tar.gz
    popd

    pushd $bdir/foo2zjs || return 1
    tar xzf $home/install/config/imprimanteP1006/sihpP1006.tar.gz
    make >>$log 2>&1
    make install >>$log 2>&1
    make install-hotplug-prog >>$log 2>&1
    popd

    service cups restart

    cp $bdir/foo2zjs/PPD/HP-LaserJet_P1006.ppd /etc/cups/ppd/
fi

lpadmin -p HP-LaserJet_P1006 -E\
 -D "HP LaserJet P1006"\
 -v usb://HP/LaserJet%20P1006?serial=AC2B302\
 -P /etc/cups/ppd/HP-LaserJet_P1006.ppd\
 -o PageSize=A4\
 || return 1

lpoptions -d HP-LaserJet_P1006
