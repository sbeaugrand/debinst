#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file scan2pdf.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    marg=$1
else
    marg=5
fi
width=`echo $marg | awk '{ print 21 - $1 * 2 / 10 }'`

cat >scan.tex <<EOF
\documentclass[a4paper]{article}
\usepackage{vmargin}
\setmarginsrb{${marg}mm}{${marg}mm}{${marg}mm}{${marg}mm}{0mm}{0mm}{0mm}{0mm}
\usepackage{graphics}
\pagestyle{empty}
\parindent0mm
\pdfimageresolution150

\begin{document}
EOF

list=`ls *.png *.jpg 2>/dev/null`
page=0
err=0
for iter in $list; do
    if [ ! -f "$iter" ]; then
        echo "error: $iter not found"
        exit 1
    fi
    if ! identify -units PixelsPerCentimeter -verbose $iter |\
       grep -q "Print size: ${width}x"; then
        if ((err == 0)); then
            echo "Todo :" >&2
        fi
        echo "convert -units PixelsPerInch $iter -density 150 $iter" >&2
        ((err++))
    fi
    if ((page > 0)); then
        echo '\\' >>scan.tex
    fi
    echo "\includegraphics{$iter}" >>scan.tex
    ((page++))
done

cat >>scan.tex <<EOF
\end{document}
EOF

if ((err != 0)); then
    exit 1
fi

pdflatex --halt-on-error scan.tex
rm scan.aux
rm scan.log
