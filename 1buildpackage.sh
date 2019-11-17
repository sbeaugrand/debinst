# ---------------------------------------------------------------------------- #
## \file 1buildpackage.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <buildpackage-...>"
    exit 1
fi
buildpackage=$1

source 0install.sh

# ---------------------------------------------------------------------------- #
# makePackage
# ---------------------------------------------------------------------------- #
makePackage()
{
    pkg=`basename $1`
    src=`dirname $1`/`echo $pkg | sed 's/^install-//'`
    dst=$buildpackage/build/$pkg-1.0
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
        mv $idir/../$pkg.tgz /tmp/
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

    echo $pkg >>$buildpackage/build/list.txt
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
rm -fr $buildpackage/build

if [ -f $buildpackage/prepare.sh ]; then
    source $buildpackage/prepare.sh
fi

for i in `cat $buildpackage/list.txt`; do
    makePackage $idir/../$i || echo " warn: package $i not completed"
done
