# ---------------------------------------------------------------------------- #
## \file install-op-lp-ts5000.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitClone https://github.com/Ordissimo/scangearmp2.git || return 1

if notWhich scangearmp2; then
    mkdir -p $bdir/scangearmp2/build
    pushd $bdir/scangearmp2/build || return 1
    PATH=$PATH:/usr/share/intltool-debian cmake -DCMAKE_INSTALL_PREFIX=$home/.local .. >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

file=$home/.local/share/applications/scangearmp2.desktop
if notFile $file; then
    cp $idir/hardware/scangearmp2.desktop $file
fi

file=$bdir/papier.pdf
if notFile $file; then
    pushd $bdir || return 1
    cat >papier.tex <<EOF
\documentclass[a4paper]{article}
\usepackage{vmargin}
\setmarginsrb{10mm}{10mm}{10mm}{10mm}{0cm}{0cm}{0cm}{0cm}
\pagestyle{empty}
\begin{document}
\begin{tabular}{rrl}
EOF
    echo "
1074 649 Carte
1500 1051 L Paysage
1051 1500 L Portrait
1800 1200 10x15cm Paysage
1200 1800 10x15cm Portrait
1748 1181 Hagaki Paysage
1181 1748 Hagaki Portrait
2102 1500 2L Paysage
1500 2102 2L Portrait
1748 2480 A5
2149 3035 B5
2550 3300 Lettre
" | awk '{
    if ($1 > 0)
        printf "%5.1f mm & %5.1f mm & %s %s\\\\\n",
            $1 * 254 / 3000, $2 * 254 / 3000, $3, $4
}' >>papier.tex
    cat >>papier.tex <<EOF
\end{tabular}
\end{document}
EOF
    pdflatex --halt-on-error papier.tex >>$log 2>&1
fi

cat <<EOF
Todo:

https://www.canon.fr/support/business-product-support/
tar xzf cnijfilter2-5.40-1-deb.tar.gz
cd cnijfilter2-5.40-1-deb
sudo apt-get install libcupsimage2
./install.sh
lpoptions -d TS5000LAN
lp.sh $file

EOF
