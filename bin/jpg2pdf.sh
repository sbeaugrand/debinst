#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file jpg2pdf.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    marg=$1
else
    marg=5
fi

cat >jpg.tex <<EOF
\documentclass[a4paper]{article}
\usepackage{vmargin}
\setmarginsrb{${marg}mm}{${marg}mm}{${marg}mm}{${marg}mm}{0mm}{0mm}{0mm}{0mm}
\usepackage{graphics}
\pagestyle{empty}
\parindent0mm
\pdfimageresolution150

\begin{document}
EOF

list=`ls *.jpg`
page=0
for iter in $list; do
    if [ ! -f "$iter" ]; then
        echo "error: $iter not found"
        exit 1
    fi
    if ((page > 0)); then
        echo '\\' >>jpg.tex
    fi
    echo "\includegraphics{$iter}" >>jpg.tex
    ((page++))
done

cat >>jpg.tex <<EOF
\end{document}
EOF

pdflatex --halt-on-error jpg.tex
rm jpg.aux
rm jpg.log
