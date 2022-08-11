# ---------------------------------------------------------------------------- #
## \file install-12-latex.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
texdir=$home/texmf

dir=$texdir/tex/latex
if notDir $dir; then
    mkdir -p $dir
fi

copyCLS()
{
    file=$1
    if notFile $dir/$file; then
        cp -a install-ob-/install-*-latex/$file $dir/
    fi
}

copyCLS lettre.cls
copyCLS enveloppe.cls
copyCLS livret.cls
copyCLS section.cls

texhash $texdir >>$log

pushd install-ob-/install-*-latex || return 1
if notFile exlettre.pdf; then
    pdflatex --halt-on-error exlettre.tex >>$log 2>&1
fi
if notFile exenv.pdf; then
    latex --halt-on-error exenv.tex >>$log 2>&1 && dvipdf exenv.dvi exenv.pdf
fi
rm -f *.aux *.log *.dvi
popd
