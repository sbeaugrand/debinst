# ---------------------------------------------------------------------------- #
## \file install-30-dns.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dns1=212.27.40.240
dns2=212.27.40.241

if notGrep "nameserver $dns1" /etc/resolv.conf; then
    echo "nameserver $dns1" >/etc/resolv.conf
    echo "nameserver $dns2" >>/etc/resolv.conf
fi
