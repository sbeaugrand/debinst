# ---------------------------------------------------------------------------- #
## \file install-11-bcm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
bcm=bcm2835-1.62
file=$bcm.tar.gz

download http://www.airspayce.com/mikem/bcm2835/$file || return 1

if notDir $bdir/$bcm; then
    pushd $bdir || return 1
    tar xzf $repo/$file
    popd
fi

if notFile /usr/local/lib/libbcm2835.a; then
    pushd $bdir/$bcm || return 1
    ./configure >>$log 2>&1
    make $MAKE_OPT >>$log 2>&1
    make install >>$log 2>&1
    popd
fi

