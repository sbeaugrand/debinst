# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-bin.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notWhich mp3server; then
    pushd $idir/projects/mp3server || return 1
    sudo -u pi\
    make C=rpi
    make C=rpi install
    popd
fi
