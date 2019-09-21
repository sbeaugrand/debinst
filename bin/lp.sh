#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file lp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <pdf> [pages] [options]"
    exit 0
fi
doc="$1"
shift

dev=`lpstat -d | grep "^system default destination:" | cut -d ' ' -f 4`
if [ -z "$dev" ]; then
    echo "todo: lpoptions -d <dev>"
    exit 1
fi
echo "dev = $dev"

if [ -n "$1" ] && [ "$1" != "-o" ]; then
    pages="-P $1"
    shift
else
    echo
    pdfinfo "$doc" | grep "^Pages:" | sed 's/[ \t]\+/ /'
    echo
fi
options="$*"

s="210 297 "`pdfinfo "$doc" | grep "^Page size:"`
l=`echo "$s" | awk '{ a=$1*72/25.4; print (int(a)>$5)?(a-$5)/2:0 }'`
t=`echo "$s" | awk '{ a=$2*72/25.4; print (int(a)>$7)?(a-$7)/2:0 }'`

if [ "$l" != 0 ] || [ "$t" != 0 ]; then
    m=`echo $l | awk '{ printf "%.1f",$0*2.54/72 }'`; echo "left = $l ($m cm)"
    m=`echo $t | awk '{ printf "%.1f",$0*2.54/72 }'`; echo " top = $t ($m cm)"
    echo -n "marges ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        margins="-o page-left=$l -o page-top=$t"
    else
        echo -n "fitplot ? (o/N) "
        read ret
        if [ "$ret" = o ]; then
            fitplot="-o fitplot"
        fi
        echo -n "marges ? (mmleft:mmtop/n) [10:10] "
        read ret
        if [ "$ret" != n ]; then
            if [ -z "$ret" ]; then
                ret=10:10
            fi
            l=`echo $ret | awk -F : '{ printf "%.1f",$1*72/25.4 }'`
            t=`echo $ret | awk -F : '{ printf "%.1f",$2*72/25.4 }'`
            margins="-o page-left=$l -o page-top=$t"
        fi
    fi
fi

echo lp -d $dev $pages $margins $fitplot $options "$doc"
echo -n "? (O/n) "
read ret
if [ "$ret" != n ]; then
    lp -d $dev $pages $margins $fitplot $options "$doc"
fi
