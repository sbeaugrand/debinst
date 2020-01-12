#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file src2html.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <src> <dst>"
    exit 1
fi
src=$1
dst=$2

ext=${src##*.}
if [ "$ext" = cls ]; then
    vim +"set ft=tex"\
        +"syntax on" +"colorscheme default" +"TOhtml"\
        +"wq" +"q" $src >/dev/null 2>/dev/null
else
    vim +"syntax on" +"colorscheme default" +"TOhtml"\
        +"wq" +"q" $src >/dev/null 2>/dev/null
fi

sed \
-e 's/bgcolor="#ffffff" text="#000000"/bgcolor="#000000" text="#ffffff"/' \
-e "s/<title>.*<\/title>/<title>`basename $src`<\/title>/" \
-e 's/000000\(; background-color: #\)ffffff/ffffff\1000000/' \
$src.html >$dst
rm $src.html
