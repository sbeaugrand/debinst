#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file dhcp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/default/isc-dhcp-server
if [ ! -f $file ]; then
    cat <<EOF

Todo:
sudo apt install iproute2 network-manager openssh-client python3 qiv make
sudo apt install isc-dhcp-server  # Failed to start

EOF
fi

intf=`ip route show to default | awk '{ print $5 }'`
if ! grep -q "$intf" $file; then
    sudo sed -i 's/^INTERFACESv4=".*"/INTERFACESv4="'$intf'"/' $file
fi

file=/etc/dhcp/dhcpd.conf
if ! grep -q "rockpi" $file; then
    tmp=/tmp/dhcpd.conf
    cp $file $tmp
    cat >>$tmp <<EOF
class "rockpi" {
  match if substring (hardware, 1, 3) = 6a:4d:37;
}
subnet 192.168.1.0 netmask 255.255.255.0 {
  pool {
    allow members of "rockpi";
    range 192.168.1.18 192.168.1.18;
  }
}
EOF
    sudo cp $tmp $file
fi

cat <<EOF

Todo:
sudo systemctl restart isc-dhcp-server

EOF
