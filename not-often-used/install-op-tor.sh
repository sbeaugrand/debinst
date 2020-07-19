# ---------------------------------------------------------------------------- #
## \file install-op-tor.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=8.0.4
file=tor-browser-linux64-${version}_fr.tar.xz
setup=start-tor-browser.desktop

download https://dist.torproject.org/torbrowser/$version/$file || return 1
untar $file tor-browser_fr/$setup || return 1

if notFile $home/.local/share/applications/$setup; then
    pushd $bdir/tor-browser_fr || return 1
    sudo -u $user ./$setup --register-app >>$log
    popd
fi
