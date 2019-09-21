# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$repo/mp3server.tgz

isFile $file || return 1

if notDir $bdir/mp3server; then
    pushd $bdir || return 1
    sudo -u pi tar xzf $file
    popd
fi

if notWhich mp3server; then
    pushd $bdir/mp3server/src || return 1
    sudo -u pi make C=rpi
    make C=rpi install
    popd
fi
