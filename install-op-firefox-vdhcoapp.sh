# ---------------------------------------------------------------------------- #
## \file install-op-firefox-vdhcoapp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.6.3
file=net.downloadhelper.coapp-$version-1_amd64.deb

if notFile $repo/$file; then
    download https://github.com/mi-g/vdhcoapp/releases/download/v$version/$file
fi

if notDir /opt/net.downloadhelper.coapp; then
    sudoRoot PATH=$PATH:/sbin dpkg -i $repo/$file
fi
