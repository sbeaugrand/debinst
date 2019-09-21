# ---------------------------------------------------------------------------- #
## \file install-op-redis.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=3.2.6
file=redis-$version.tar.gz

download http://download.redis.io/releases/$file || return 1
untar $file || return 1

if notWhich redis-server; then
    pushd $bdir/redis-$version/deps || return 1
    make hiredis lua jemalloc linenoise geohash-int >>$log 2>&1
	popd

    pushd $bdir/redis-$version || return 1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi
