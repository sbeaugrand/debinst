# ---------------------------------------------------------------------------- #
## \file install-op-ctparent.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

cat <<EOF

sudo aptitude install dnsmasq lighttpd lighttpd-mod-magnet php-cgi php-xml
sudo aptitude install libnotify-bin iptables-persistent e2guardian privoxy
sudo aptitude install libnss3-tools console-data dnsutils openssh-server
sudo aptitude install gamin
sudo dpkg -i ctparental_debian9_lighttpd_4.30.08-1.0_all.deb

EOF
