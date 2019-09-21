# ---------------------------------------------------------------------------- #
## \file install-12-latex.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
path=/usr/share/texlive/texmf-dist/tex/latex

copyCLS()
{
    file=$1
    if notFile $path/$file; then
        cp -a install-12-latex/$file $path/
    fi
}

copyCLS lettre.cls
copyCLS enveloppe.cls
copyCLS livret.cls
copyCLS section.cls

texhash >>$log

pushd install-12-latex || return 1
if notFile exlettre.pdf; then
    pdflatex --halt-on-error exlettre.tex >>$log 2>&1
fi
if notFile exenv.pdf; then
    latex --halt-on-error exenv.tex >>$log 2>&1 && dvipdf exenv.dvi exenv.pdf
fi
rm -f *.aux *.log *.dvi
popd
