# ---------------------------------------------------------------------------- #
## \file install-op-ctparental.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cat <<EOF

https://gitlab.com/marsat/CTparental/-/wikis/installation-fr#pour-debian-10
https://gitlab.com/marsat/CTparental/-/tags
sudo apt-get update
sudo apt-get install gdebi-core
sudo gdebi ctparental_debian10_lighttpd_4.44.09-1.0_all.deb
#sudo CTparental -uhtml
https://admin.ct.local/

EOF
