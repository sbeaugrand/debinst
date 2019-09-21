# ---------------------------------------------------------------------------- #
## \file install-op-docker.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=docker-ce_17.12.0~ce-0~debian_amd64.deb
url=https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64

download $url/$file || return 1

if notWhich vagrant; then
    dpkg -i $repo/$file >>$log
fi
