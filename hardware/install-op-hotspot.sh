# ---------------------------------------------------------------------------- #
## \file install-op-hotspot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Client ip example : 10.66.0.3 gateway 10.66.0.2
## \note File transfert example :
##       server> python3 -m http.server
##       client> http://10.66.0.2:8000
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
 wifi.hidden yes\
 wifi.mode ap\
 ssid $name\
 ipv4.addresses $ip/24\
 ipv4.gateway $gateway\
 ipv4.method shared\
 ipv6.method shared\
 wifi-sec.key-mgmt wpa-psk\
 wifi-sec.psk "$psk"
fi

if ! systemctl -q is-enabled nftables; then
    sudoRoot systemctl enable nftables
fi
if ! systemctl -q is-active nftables; then
    sudoRoot systemctl start nftables
fi

logTodo "client ip example $client gateway $ip"
