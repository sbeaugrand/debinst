# ---------------------------------------------------------------------------- #
## \file install-op-flashplayer.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://get.adobe.com/flashplayer/
##       rm ~/data/install-repo/flash_player_npapi_linux.x86_64.tar.gz
##       rm -fr ~/data/install-build/flashplayer
##       sudo rm /usr/lib/mozilla/plugins/libflashplayer.so
# ---------------------------------------------------------------------------- #
file=flash_player_npapi_linux.x86_64.tar.gz
url="https://fpdownload.adobe.com/get/flashplayer/pdc/32.0.0.255"

download $url/$file || return 1
untar $file flashplayer/libflashplayer.so flashplayer || return 1

if notFile /usr/lib/mozilla/plugins/libflashplayer.so; then
    pushd $bdir/flashplayer || return 1
    cp libflashplayer.so /usr/lib/mozilla/plugins/
    cp -r usr/* /usr
    popd
fi
