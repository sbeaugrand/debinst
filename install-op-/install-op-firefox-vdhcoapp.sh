# ---------------------------------------------------------------------------- #
## \file install-op-firefox-vdhcoapp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=2.0.10
file=vdhcoapp-$version-linux-x86_64.deb

if notFile $repo/$file; then
    download https://github.com/aclap-dev/vdhcoapp/releases/download/v$version/$file
fi

if notDir /opt/net.downloadhelper.coapp; then
    sudoRoot PATH=$PATH:/sbin dpkg -i $repo/$file
fi
