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

if [ -z "$1" ]; then
    echo "Usage: `basename $0` <local-pdf> [<metafont-src>=<metafont-dst>]..."
    echo "Ex:    `basename $0` local.pdf frcr10=frcf10 frcr14=frcf14"
    exit 1
fi

src=$1
dst=${1%.*}.ngc
shift
fonts=$*
mpsrc=$tmp/${src%.*}.mp
pdfsrc=$tmp/${src%.*}-1.pdf

# mpsrc
if [ $src -nt $mpsrc ] || [ $0 -nt $mpsrc ]; then
    for f in $fonts; do
        srcfont=`echo $f | cut -d '=' -f 1`
        dstfont=`echo $f | cut -d '=' -f 2`
        awkfonts="$awkfonts font[\"$srcfont.mp;\"] = \"$dstfont.mp;\";"
    done
    pstoedit -q -pta -nomaptoisolatin1 -f mpost $src $mpsrc.ori
    sed -e 's/\r/" \& char(13) \& "/'\
     -e "s/^defaultfont[^+]*+\([^\"]*\)\";/input \1.mp;/"\
     -e 's/fontsize defaultfont/font_size/' $mpsrc.ori |\
     awk 'BEGIN {'"$awkfonts"' }
{
    for(i = 1; i <= NF; i++) {
        if ($i in font) {
            printf font[$i];
        } else {
            printf "%s",$i;
        }
        if (i < NF) {
            printf " ";
        }
    }
    printf "\n";
}' >$mpsrc
fi

# mkfont
mkfont()
{
    font=$1
    mpfont=$tmp/$font.mp

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
            modified=y
        fi
    done

    # mpfont
    first=`echo $list | cut -d ' ' -f 1`
    if [ $first -nt $mpfont ] || [ $0 -nt $mpfont ] || [ "$modified" = y ]; then
        file=`find ~/texmf/fonts/source/ -name $font.mf`
        size=`grep font_size $file | cut -d ' ' -f 2`
        cat >$mpfont <<EOF
font_size := $size;
vardef showtext(expr origin)(expr angle)(expr str) =
newinternal numeric num;
if str = "":
  num := 0;
elseif str = " ":
  num := 9;
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
        modified=y
    fi
}
for f in $fonts; do
    font=`echo $f | cut -d '=' -f 2`
    mkfont $font
done

# pdfsrc
if [ $mpsrc -nt $pdfsrc ] || [ "$modified" = y ]; then
    cd $tmp
    mptopdf `basename $mpsrc`
    cd - >/dev/null
fi

# dst
if [ $pdfsrc -nt $dst ]; then
    pstoedit -q -f gcode $pdfsrc $dst
    sed -i 's/G01 Z/G00 Z/' $dst
fi
