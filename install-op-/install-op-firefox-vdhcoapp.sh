# ---------------------------------------------------------------------------- #
## \file install-op-firefox-vdhcoapp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# https://github.com/aclap-dev/vdhcoapp/releases/latest
version=2.0.19
file=vdhcoapp-linux-x86_64.deb
url=https://github.com/aclap-dev/vdhcoapp/releases/download/v$version/$file

if notFile $repo/$file; then
    download $url || return 1
fi

if notDir /opt/vdhcoapp; then
    sudoRoot PATH=$PATH:/sbin dpkg -i $repo/$file
fi
