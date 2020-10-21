# ---------------------------------------------------------------------------- #
## \file install-op-font-morse.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
texdir=/usr/share/texmf
repo=$idir/../repo

download http://mirrors.ctan.org/fonts/morse.zip || return 1

if notDir $bdir/morse; then
    pushd $bdir || return 1
    unzip -qq $repo/morse.zip
    popd
fi

if notFile $texdir/tex/latex/morse/morse.sty; then
    pushd $bdir/morse || return 1
    mkdir -p          $texdir/fonts/source/public/morse
    cp -f morse10.mf  $texdir/fonts/source/public/morse/
    cp -f morse.alf   $texdir/fonts/source/public/morse/
    cp -f morse.def   $texdir/fonts/source/public/morse/
    cp -f morse.num   $texdir/fonts/source/public/morse/
    mkdir -p          $texdir/fonts/tfm/public/morse
    cp -f morse10.tfm $texdir/fonts/tfm/public/morse/
    mkdir -p          $texdir/tex/latex/morse
    cp -f morse.sty   $texdir/tex/latex/morse/
    texhash >>$log
    popd
fi
