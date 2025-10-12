#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file bom.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note ../makefiles/bom.awk README.md | tee bom.md
##       pandoc bom.md --metadata title=BOM -f markdown -t html -s -o bom.html
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
        printf "|%s|%6.2f|%s|%6.2f|\n",$2,$3,$4,t2;
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
