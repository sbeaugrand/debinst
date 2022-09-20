# ---------------------------------------------------------------------------- #
## \file install-op-hotspot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=hotspot
netId=10.66.0
client=$netId.3
ip=$netId.2
gateway=192.168.0.254
# psk
file=$idir/hardware/install-pr-hotspot.sh
if isFile $file; then
    source $file
else
    echo -n " psk ? "
    read psk
fi

file=/etc/NetworkManager/system-connections/$name.nmconnection
if notFile $file; then
    sudoRoot nmcli c add\
 type wifi\
 con-name $name\
 autoconnect no\
 802-11-wireless.hidden yes\
 802-11-wireless.mode ap\
 ssid $name\
 ipv4.addresses $ip/24\
 ipv4.gateway $gateway\
 ipv4.method shared\
 ipv6.method shared\
 wifi-sec.key-mgmt wpa-psk\
 wifi-sec.psk "$psk"
fi

echo " info: client ip example $client gateway $ip"
