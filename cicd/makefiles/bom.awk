#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file bom.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note vi Makefile
##       .PHONY: bom
##       bom: bom.html
##       bom.html: bom.md
##           @../makefiles/bom.awk $< | tee bom.tmp~
##           @mv bom.tmp~ $<
##           @pandoc $< --metadata title=BOM -f markdown -t html -s -o $@
# ---------------------------------------------------------------------------- #
BEGIN {
    FS = "|";
    t1 = 0;
    t2 = 0;
    state = 0;
}
{
    if (state == 0 && substr($2, 1, 5) == "-----") {
        state = 1;
        print $0;
    } else if (state != 1) {
        print $0;
    } else if (substr($2, 0, 5) == "Total") {
        state = 2;
        printf "|%s|%6.2f|%s|%6.2f|\n",$2,t1,$4,t2;
    } else {
        t1 += $3;
        t = $3;
        split($4, a, "/", seps)
        for (i in a) {
            if (i == 1) {
                t *= a[i];
            } else {
                t /= a[i];
            }
        }
        t2 += t;
        printf "|%s|%6.2f|%s|%6.2f|\n",$2,$3,$4,t;
    }
}
