# ---------------------------------------------------------------------------- #
## \file install-op-lp-et2860.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://support.epson.net/linux/Printer/LSB_less_distribution_pages/en/escpr.php
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
url="https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=JA&CN2=US&CTI=176&PRN=Linux%20deb%2064bit%20package&OSC=LX&DL"

file=epson-inkjet-printer-escpr_1.8.5-1_amd64.deb
download "$url" $file || return 1

if notDir /opt/epson-inkjet-printer-escpr; then
    sudoRoot dpkg -i $repo/$file
fi

name=EPSON_ET-2860_Series

file=/etc/cups/ppd/$name.ppd
if notFile $file; then
    gunzip -c /opt/epson-inkjet-printer-escpr/ppds/Epson/Epson-ET-2860_Series-epson-inkjet-printer-escpr.ppd.gz >$tmpf
    sudoRoot cp $tmpf $file
    sudoRoot chown root:lp $file
    sudoRoot systemctl restart cups
fi

sudoRoot lpadmin -p "$name" -E\
 -D "'EPSON ET-2860 Series'"\
 -v "'usb://EPSON/ET-2860%20Series?serial=5843584A3033343353&interface=1'"\
 || return 1

lpoptions -d "$name"
