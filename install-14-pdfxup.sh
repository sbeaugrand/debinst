#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-14-pdfxup.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$home/.local/bin
if notDir $dir; then
    mkdir -p $dir
fi

pdfxup=/usr/bin/pdfxup
if notGrep "2021" $pdfxup; then
    file=$dir/pdfxup
    if notFile $file; then
        cp $pdfxup $file
        patch -p0 $file >>$log <<EOF
--- /usr/bin/pdfxup     2020-12-18 23:11:58.000000000 +0100
+++ $home/.local/bin/pdfxup        2021-09-24 12:12:05.068126410 +0200
@@ -453,7 +453,7 @@
 ######################################################################
 ## GS could be specified from command-line
 : \${GS=\`which gs\`}
-GSVERSION=\`\$GS --version 2>/dev/null\`;
+GSVERSION=\`\$GS --version 2>/dev/null | awk -F . '{ print \$1"."\$2 }'\`;
 if [ ! "\$GSVERSION" ]; then
     echo "   /!\\\\ ghostscript not found; aborting.";
     exit 1;
EOF
    fi
fi
