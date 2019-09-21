# ---------------------------------------------------------------------------- #
## \file install-op-crosstool.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=crosstool-ng-1.23.0.tar.bz2

download http://crosstool-ng.org/download/crosstool-ng/$file || return 1
untar $file || return 1

if notDir $home/x-tools; then
    pushd $bdir/id3ed-$version || return 1
    ./configure -enable-local >>$log 2>&1
    ct-ng armv6-rpi-linux-gnueabi >>$log
    ct-ng build >>$log
    popd
fi
