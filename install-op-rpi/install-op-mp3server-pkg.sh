# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
untar mp3server.tgz || return 1

if notWhich mp3server; then
    pushd $bdir/mp3server || return 1
    sudo -u pi make C=rpi
    make C=rpi install
    popd
fi
