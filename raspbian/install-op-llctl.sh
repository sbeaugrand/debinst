# ---------------------------------------------------------------------------- #
## \file install-op-llctl.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=llctl.tgz
download https://www.raspberrypi.org/forums/download/file.php\?id\=6355 $file
if notFile $repo/$file; then
    cp install-op-llctl/$file $repo/
fi
untar $file llctl/llctl.c llctl || return 1

file=/usr/local/bin/llctl
if notFile $file; then
    pushd $bdir/llctl || return 1
    gcc llctl.c -lusb -o llctl >>$log 2>&1
    cp llctl $file
    popd
fi
