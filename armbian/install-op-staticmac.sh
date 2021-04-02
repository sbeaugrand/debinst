# ---------------------------------------------------------------------------- #
## \file install-op-staticmac.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/network/interfaces.d/10-staticmac
intf=eth0

if notFile $file; then
    echo "allow-hotplug $intf" >$file
    echo "iface $intf inet dhcp" >>$file
    echo -n "hwaddress ether " >>$file
    cat /sys/class/net/$intf/address >>$file
fi
