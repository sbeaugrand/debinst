# ---------------------------------------------------------------------------- #
## \file install-op-lp-ts5000.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

cat <<EOF

https://www.canon.fr/support/business-product-support/
tar xzf cnijfilter2-5.40-1-deb.tar.gz
cd cnijfilter2-5.40-1-deb
./install.sh
lpoptions -d TS5000LAN

https://github.com/Ordissimo/scangearmp2/releases
https://github.com/Ordissimo/scangearmp2/releases/download/3.40.3/scangearmp2_3.40.3.debian.stretch_amd64.deb
dpkg -i
echo "canon_pixma" >>/etc/sane.d/dll.conf
scanimage -L
device `canon_pixma:F4-A9-97-8C-EF-7A' is a CANON TS5000 series flatbed scanner

EOF
