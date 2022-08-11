# ---------------------------------------------------------------------------- #
## \file install-op-crosstool.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=crosstool-ng-1.24.0

file=$name.tar.bz2
download http://crosstool-ng.org/download/crosstool-ng/$file || return 1
untar $file || return 1

if notDir $home/x-tools; then
    pushd $bdir/$name || return 1
    ./configure -enable-local >>$log 2>&1
    make >>$log 2>&1
    ct-ng armv6-rpi-linux-gnueabi >>$log
    ct-ng build >>$log
    popd
fi
