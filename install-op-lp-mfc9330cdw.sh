# ---------------------------------------------------------------------------- #
## \file install-op-lp-mfc9330cdw.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notDir /opt/brother/Printers/mfc9330cdw/lpd; then
    dpkg -i --force-architecture $repo-siemens/mfc9330cdwlpr-1.1.2-1.i386.deb
fi

if notDir /opt/brother/Printers/mfc9330cdw/cupswrapper; then
    dpkg -i --force-architecture\
 $repo-siemens/mfc9330cdwcupswrapper-1.1.4-0.i386.deb
fi

lpadmin -p MFC9330CDW -E\
 -D "MFC9330CDW"\
 -v socket://192.168.1.99\
 -o PageSize=A4\
 -o Duplex=DuplexNoTumble\
 || return 1

lpoptions -d MFC9330CDW
