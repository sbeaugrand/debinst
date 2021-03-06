# ---------------------------------------------------------------------------- #
## \file install-16-latex-ex.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd latex/divers || return 1
for f in illusion carte carte2 clarky declinaison; do
    if notFile $f.pdf; then
        if grep -q pstricks $f.tex; then
            sudo -u $user latex --halt-on-error $f.tex >>$log 2>&1
            sudo -u $user dvipdf -dALLOWPSTRANSPARENCY $f.dvi $f.pdf >>$log 2>&1
        else
            sudo -u $user pdflatex --halt-on-error $f.tex >>$log 2>&1
        fi
        if ! isFile $f.pdf; then
            return 1
        fi
    fi
done
rm -f *.aux *.log *.dvi
popd
