#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file png2pdf.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    marg=$1
else
    marg=5
fi

cat >png.tex <<EOF
\documentclass[a4paper]{article}
\usepackage{vmargin}
\setmarginsrb{${marg}mm}{${marg}mm}{${marg}mm}{${marg}mm}{0mm}{0mm}{0mm}{0mm}
\usepackage{graphics}
\pagestyle{empty}
\parindent0mm
\pdfimageresolution150

\begin{document}
EOF

list=`ls *.png`
page=0
for iter in $list; do
    if [ ! -f "$iter" ]; then
        echo "error: $iter not found"
        exit 1
    fi
    if ((page > 0)); then
        echo '\\' >>png.tex
    fi
    echo "\includegraphics{$iter}" >>png.tex
    ((page++))
done

cat >>png.tex <<EOF
\end{document}
EOF

pdflatex --halt-on-error png.tex
rm png.aux
rm png.log
