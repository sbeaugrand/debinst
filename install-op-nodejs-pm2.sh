# ---------------------------------------------------------------------------- #
## \file install-op-nodejs-pm2.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=v6.10.3

if notWhich npm; then
    pushd /usr/bin || return 1
    ln -sf $bdir/node-$version-linux-x64/bin/npm
    popd
fi

if notFile $bdir/node-$version-linux-x64/bin/pm2; then
    sudo -u $user npm install pm2 -g
fi

if notWhich pm2; then
    pushd /usr/bin || return 1
    ln -sf $bdir/node-$version-linux-x64/bin/pm2
    popd
fi
