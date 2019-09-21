# ---------------------------------------------------------------------------- #
## \file install-op-nodejs-base.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=v6.10.3
file=node-$version-linux-x64.tar.xz

download https://nodejs.org/dist/$version/$file || return 1
untar $file || return 1

if notWhich node; then
    pushd /usr/bin || return 1
    ln -sf $bdir/node-$version-linux-x64/bin/node
    popd
fi
