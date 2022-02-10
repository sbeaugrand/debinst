#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 1buildpackage.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <buildpackage-...> <tar|dist>"
    exit 1
fi
buildpackage=$1
tardist=$2

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
    echo "make: $pkg (src=$src, dst=$dst)" | tee -a $log

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
        make $tardist >>$log
        if [ $tardist = "dist" ]; then
            mv $idir/../$pkg-dist.tgz /tmp/$pkg.tgz
        else
            mv $idir/../$pkg.tgz /tmp/
        fi
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
list=`find . -name "*.sh" -exec grep -q '^repo=\$idir' {} \; -print |\
 grep -v build | cut -c3-`
for f in $list; do
    if echo "$f" | grep -q "buildpackage-"; then
        continue
    fi
    if echo "$f" | grep -q "not-often-used"; then
        continue
    fi
    if ! grep -q "source $f" $buildpackage/prepare.sh; then
        echo "warn: $buildpackage/prepare.sh: missing source $f"
    fi
    pkg="install-"`grep '^repo=\$idir' "$f" | awk -F / '{ print $NF }'`
    if ! grep -q "$pkg" $buildpackage/list.txt; then
        echo "warn: $buildpackage/list.txt: missing $pkg"
    fi
done

rm -fr $buildpackage/build

if [ -f $buildpackage/prepare.sh ]; then
    source $buildpackage/prepare.sh || echo "error"
fi

for i in `cat $buildpackage/list.txt`; do
    if [ "${i:0:1}" = '#' ]; then
        continue
    fi
    makePackage $idir/../$i || echo "warn: package $i not completed"
done

echo "to save: "
echo "echo \""
pushd $home
ls -1 -d 2>/dev/null\
 .ssh/id*\
 .ssh/authorized_keys\
 .gnupg\
 .config/supertuxkart/*/*.xml\
 .config/libreoffice/*/user/pack/wordbook/*\
 .local/share/evolution/addressbook/system/contacts.db
dir=`ls -d 2>/dev/null .mozilla/firefox/*.default*/bookmarkbackups`
if [ -n "$dir" ]; then
    dir=`readlink -f $dir/.. | sed "s#$home/##"`
    for d in $dir; do
        ls -1 -d $d/key4.db $d/logins.json $d/bookmarkbackups
    done
fi
echo "\" | tar cvzf ~/save.tgz -T-"
popd
