#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file untar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <archive> [--no-delete]"
    exit 1
fi
archve=$1
shift
if [ ! -f $archive ]; then
    echo "error: $archive not found"
    exit 1
fi

tmp=/tmp/untar.tmp
rm -fr $tmp
quit()
{
    rm -fr $tmp
    exit $1
}
trap "echo; quit 0" SIGINT

mkdir $tmp
tar xzf $archve -C $tmp
list=`find $tmp -maxdepth 1 -type d | sed "s@$tmp/@@" | sed "s@$tmp@@"`
for d in $list; do
    if [ ! -e $tmp/$d ]; then
        echo "error: $tmp/$d not found"
        exit 1
    fi
    if [ ! -d $d ]; then
        echo -n "mkdir $d ? [O/n] "
        read ret
        if [ "$ret" != n ]; then
            mkdir -p $d
        fi
    fi
    cmd="rsync.sh $tmp/$d $d $*
 -f'-r_build/***'
 -f'-r_*.pdf'
 -f'-r_*.a'
 -f'-r_*.ko'
 -f'-r_*.dtbo'
 -f'-r_*.hex'
 -f'-r_*.ged'
 -f'-r_*.7z'
 -f'-r_homepage/html/***'
 -f'-r_homepage/images/***'
 -f'-r_homepage/tgz/***'
 -f'-r_.git'"
    echo $cmd
    eval $cmd
done
quit 0
