# ---------------------------------------------------------------------------- #
## \file install-11-bcm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
bcm=bcm2835-1.63
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

file=$bcm.tar.gz
download http://www.airspayce.com/mikem/bcm2835/$file || return 1
untar $file || return 1

if notFile /usr/local/lib/libbcm2835.a; then
    pushd $bdir/$bcm || return 1
    ./configure >>$log 2>&1
    make $MAKE_OPT >>$log 2>&1
    make install >>$log 2>&1
    popd
fi
