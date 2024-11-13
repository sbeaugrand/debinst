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
## \fn downloadWheel
# ---------------------------------------------------------------------------- #
downloadWheel()
{
    args="$1"
    name=`echo $args | awk '{ print $NF }'`

    if [ `uname -m` = "x86_64" ]; then
        wheels="$idir/../wheels-amd64"
    else
        #wheels="$idir/../wheels-`uname -m`"
        logWarn "wheels download is disabled on `uname -m`"
        return
    fi
    mkdir -p $wheels

    if ls -1 $wheels | grep -q -i "^$name-"; then
        logWarn "wheel $name already exists"
        ls -1 $wheels | grep -i "^$name-" | cut -d '-' -f 2
        pip3 install $name== 2>&1 | grep versions |\
            awk '{ print gensub(")", "", 1, $NF) }'
        return
    fi

    pip3 wheel -w $wheels --prefer-binary $args
}

# ---------------------------------------------------------------------------- #
## \fn makePackage
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
## \fn rSourceList
# ---------------------------------------------------------------------------- #
rSourceList()
{
    f=$1
    echo "$f" >>$tmp
    l=`grep "^source " $f | sed 's/^source //'`
    if grep -q "sourceList " $f; then
        l="$l `sed -n '/sourceList/,/"/{/"/!p}' $f | sed 's/#//'`"
    fi
    for f in $l; do
        rSourceList `echo $f | sed 's@\$idir/@@'`
    done
}

# ---------------------------------------------------------------------------- #
## \fn check
# ---------------------------------------------------------------------------- #
check()
{
    list=`find . -name "*.sh" -exec grep -q '^repo=\$idir' {} \; -print |\
     grep -v build | cut -c3-`
    tmp=/tmp/1buildpackage.tmp
    cat /dev/null >$tmp
    rSourceList $buildpackage/prepare.sh
    sourceList=`cat $tmp`
    for f in $list; do
        if echo "$f" | grep -q "buildpackage-"; then
            continue
        fi
        if echo "$f" | grep -q "not-used"; then
            continue
        fi
        if echo "$f" | grep -q "5updaterepo"; then
            continue
        fi
        found=n
        for s in $sourceList; do
            if grep -q "$f" $s; then
                found=y
                break
            fi
        done
        if [ "$found" = n ]; then
            logTodo "$buildpackage/prepare.sh: missing $f"
        fi
        pkg="install-"`grep '^repo=\$idir' "$f" | awk -F / '{ print $NF }'`
        if ! grep -q "$pkg" $buildpackage/list.txt; then
            logTodo "$buildpackage/list.txt: missing $pkg"
        fi
    done
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
rm -fr $buildpackage/build

if [ -f $buildpackage/prepare.sh ]; then
    check
    source $buildpackage/prepare.sh || echo "error"
fi

for i in `cat $buildpackage/list.txt`; do
    if [ "${i:0:1}" = '#' ]; then
        continue
    fi
    makePackage $idir/../$i || echo "warn: package $i not completed"
done

echo "to save: "
echo "cd && echo \""
pushd $home
ls -1 -d 2>/dev/null\
 .ssh/id*\
 .ssh/authorized_keys\
 .gnupg\
 .password-store\
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
