#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file src2html.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
trans()
{
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
    file=$src.html
    sed 's/bgcolor="#ffffff" text="#000000"/bgcolor="#000000" text="#ffffff"/'\
      $file | sed "s/<title>.*<\/title>/<title>`basename $src`<\/title>/" >$dst
    sed -i 's/000000\(; background-color: #\)ffffff/ffffff\1000000/' $dst
    rm -f $file
}

quit()
{
    tar chzf tgz/src.tgz $list
    exit 0
}
trap "echo; quit" SIGINT

list=`find . -type l -! -exec test -e {} \; -print`
if [ -n "$list" ]; then
    echo "error: $list not found"
    exit 1
fi

list=`ls -tL\
 src/*.c\
 src/*.sh\
 src/*.tex\
 src/*.cls\
 src/*.patch\
 src/*.el\
 src/*.mf\
 src/*.mk\
 2>/dev/null | tr '\n' ' '`
for i in $list; do
    dst=${i%.*}
    dst=html/${dst#*/}.html
    echo -n "$i ==> $dst ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        trans $i $dst
    fi
done

quit
