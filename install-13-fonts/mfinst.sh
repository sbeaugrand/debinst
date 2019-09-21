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
texdir=/usr/share/texmf

if [ -z "$1" ]; then
    echo "Usage: `basename $0` <font.mf>"
    exit 0
fi
name=${1%.mf}

user=`whoami`
if [ $user != "root" ]; then
    su -c "$0 $*"
    exit $?
fi

mkdir -p $texdir/tex/latex/$name

cat >$texdir/tex/latex/$name/$name.sty << EOF
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{$name}
\newcommand{\\$name}[1]{{\fontencoding{T1}\fontfamily{$name}\selectfont #1}}
\endinput
EOF

cat >$texdir/tex/latex/$name/t1$name.fd << EOF
\ProvidesFile{t1$name.fd}
\DeclareFontFamily{T1}{$name}{}
\DeclareFontShape{T1}{$name}{m}{n}{<-> $name}{}
\endinput
EOF

mkdir -p $texdir/fonts/source/public/$name
cp -f $name.mf $texdir/fonts/source/public/$name/
texhash >/dev/null
