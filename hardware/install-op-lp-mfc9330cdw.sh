# ---------------------------------------------------------------------------- #
## \file install-op-lp-mfc9330cdw.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
export PATH=$PATH:/sbin
url=http://download.brother.com/welcome

file=mfc9330cdwlpr-1.1.2-1.i386.deb
download $url/dlf100400/$file || return 1

if notDir /opt/brother/Printers/mfc9330cdw/lpd; then
    dpkg -i --force-architecture $repo/$file
fi

file=mfc9330cdwcupswrapper-1.1.2-1.i386.deb
download $url/dlf100402/$file || return 1

if notDir /opt/brother/Printers/mfc9330cdw/cupswrapper; then
    dpkg -i --force-architecture $repo/$file
fi

lpadmin -p MFC9330CDW -E\
 -D "MFC9330CDW"\
 -v "usb://Brother/MFC-9330CDW?serial=E71818B4J347585"\
 -o PageSize=A4\
 -o Duplex=DuplexNoTumble\
 || return 1
# -v socket://192.168.1.99\

lpoptions -d MFC9330CDW
