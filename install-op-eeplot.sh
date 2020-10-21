# ---------------------------------------------------------------------------- #
## \file install-op-eeplot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

gitClone https://neo900.org/git/eeshow.git || return 1

file=$bdir/eeshow/kicad/pl-render.c
if notGrep "suppress_page_layout = 1" $file; then
    pushd $bdir/eeshow || return 1
    git apply $idir/install-op-eeplot.patch
    popd
fi

file=$bdir/eeshow/.gitignore 
if notFile $file; then
    cat >$file <<EOF
*.d
*.o
*.hex
*.inc
eediff
eeplot
eeshow
eetest
EOF
fi

if notWhich eeplot; then
    pushd $bdir/eeshow || return 1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi
