#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file pdftogcode.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
tmp=${TMPDIR:-/tmp}
if [ -d build ]; then
    tmp=build
fi

if [ -z "$2" ]; then
    echo "Usage: `basename $0` <local-pdf> <metafont>"
    echo "Ex:    `basename $0` <local.pdf> <frcf10>"
    exit 1
fi

src=$1
dst=${src%.*}.ngc
font=$2
mpfont=$tmp/$font.mp
mpsrc=$tmp/${src%.*}.mp
pdfsrc=$tmp/${src%.*}-1.pdf

# mpsrc
if [ $src -nt $mpsrc ]; then
    pstoedit -q -pta -nomaptoisolatin1 -f mpost $src $mpsrc.ori
    sed -e 's/^showtext /showchar /'\
     -e 's/\r/" \& char(13) \& "/'\
     -e '/^defaultfont/d'\
     -e "s/^beginfig/input $font.mp;\nbeginfig/" $mpsrc.ori >$mpsrc
fi

# font.[0-9]*
list=`ls -1 $tmp/$font.*[0-9] 2>/dev/null | sort -t. -k2 -n`
if [ -z "$list" ]; then
    cd $tmp
    mpost '&mfplain \mode=localfont; input' $font
    cd - >/dev/null
    list=`ls -1 $tmp/$font.*[0-9] 2>/dev/null | sort -t. -k2 -n`
fi

# font.[0-9]*.mp
for f in $list; do
    if [ $f -nt $f.mp ]; then
        echo $f
        pstoedit -q -f mpost $f $f.mp
    fi
done

# mpfont
first=`echo $list | cut -d ' ' -f 1`
if [ $first -nt $mpfont ] || [ $0 -nt $mpfont ]; then
    cat >$mpfont <<EOF
vardef showchar(expr origin)(expr angle)(expr str) =
newinternal numeric num;
if str = "":
  num := 0;
else:
  num := ASCII(str);
fi
EOF
    for f in $list; do
        n=`echo $f | cut -d. -f2`
        echo "elseif num = $n:" >>$mpfont
        sed -n '/^beginfig/,/endfig/{/endfig/!p}' $f.mp | sed '1d' |\
         sed 's/draw/  draw p scaled defaultscale shifted origin;\n  path p;\n  p =/' |\
         sed 's/fill/  draw p scaled defaultscale shifted origin;\n  path p;\n  p =/' |\
         sed '0,/draw/{/draw/d}' >>$mpfont
        echo "  draw p scaled defaultscale shifted origin;" >>$mpfont
    done
    echo "fi" >>$mpfont
    echo "enddef;" >>$mpfont
    sed -i '0,/elseif num/{s/elseif num/if num/}' $mpfont
fi

# pdfsrc
if [ $mpsrc -nt $pdfsrc ] || [ $mpfont -nt $pdfsrc ]; then
    cd $tmp
    mptopdf `basename $mpsrc`
    cd - >/dev/null
fi

# dst
if [ $pdfsrc -nt $dst ]; then
    pstoedit -q -f gcode $pdfsrc $dst
    sed -i 's/G01 Z/G00 Z/' $dst
fi
