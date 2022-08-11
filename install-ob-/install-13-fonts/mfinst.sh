#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mfinst.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Pour convertir en TTF :
# mftrace --formats=ttf $name.mf
# ---------------------------------------------------------------------------- #
home=${home:-$HOME}
texdir=$home/texmf

if [ -z "$1" ]; then
    echo "Usage: `basename $0` <font.mf>"
    exit 0
fi
name=${1%.mf}

dir=$texdir/tex/latex/$name
if [ ! -d $dir ]; then
    mkdir -p $dir
fi

cat >$dir/$name.sty << EOF
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{$name}
\newcommand{\\$name}[1]{{\fontencoding{T1}\fontfamily{$name}\selectfont #1}}
\endinput
EOF

cat >$dir/t1$name.fd << EOF
\ProvidesFile{t1$name.fd}
\DeclareFontFamily{T1}{$name}{}
\DeclareFontShape{T1}{$name}{m}{n}{<-> $name}{}
\endinput
EOF

dir=$texdir/fonts/source/public/$name
if [ ! -d $dir ]; then
    mkdir -p $dir
fi

cp -f $name.mf $dir/
texhash $dir >/dev/null
