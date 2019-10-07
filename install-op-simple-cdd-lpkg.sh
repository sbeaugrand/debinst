# ---------------------------------------------------------------------------- #
## \file install-op-simple-cdd-lpkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# removeInMirror
# ---------------------------------------------------------------------------- #
removeInMirror()
{
    mirror=$1
    if [ -d $mirror ]; then
        pushd $mirror
        reprepro remove stable $pkg >>$log 2>&1
        popd
    fi
}

# ---------------------------------------------------------------------------- #
# makePackage
# ---------------------------------------------------------------------------- #
makePackage()
{
    pkg=`basename $1`
    src=`dirname $1`/`echo $pkg | sed 's/^install-//'`
    dst=install-op-simple-cdd-lpkg/build/$pkg-1.0
    mkdir -p $dst
    echo " make: $pkg (src=$src, dst=$dst)" | tee -a $log

    isDir $src || return 1

    pushd $dst || return 1
    dh_make --native --indep --yes >>$log
    popd

    pushd $dst/debian || return 1
    rm -f *.ex *.EX
    echo "data/* /usr/share/$pkg/" >$pkg.install
    popd

    dir=`basename $src`
    if [ -f $src/Makefile ]; then
        pushd $src || return 1
        make tar >>$log
        mv ../$pkg.tgz /tmp/
        popd
    else
        pushd $src/.. || return 1
        tar czf /tmp/$pkg.tgz $dir >>$log
        popd
    fi

    pushd $dst || return 1
    tar xzf /tmp/$pkg.tgz --transform "s/^$dir/data/"
    dpkg-buildpackage --no-sign >>$log 2>&1
    popd

    removeInMirror $bdir/simple-cdd-amd64/tmp/mirror
    removeInMirror $bdir/simple-cdd-i386/tmp/mirror
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
rm -fr install-op-simple-cdd-lpkg/build

repoSav=$repo
source install-op-codecs.sh
source install-op-ffmpeg-src.sh
source install-op-mplayer-src.sh
source install-14-cal.sh
source install-op-arduino.sh
source install-17-rdm.sh
source install-op-emacs-php.sh
source install-op-id3ed.sh
source install-op-mp3gain.sh
repo=$repoSav
source install-op-sdcc-src.sh

# libdvdcss
/usr/lib/libdvd-pkg/b-i_libdvdcss.sh
file=`ls -1 -rt /usr/src/libdvd-pkg/*.bz2 | tail -n 1`
if [ -z "$file" ]; then
    echo " error: /usr/src/libdvd-pkg/*.bz2 not found" | tee -a $log
    return 1
fi
repo=$idir/../libdvdcss
mkdir -p $repo
cp -au $file $repo

for i in `cat install-op-simple-cdd/list2.txt`; do
    makePackage $idir/../$i || echo " warn: package $i not completed"
done
