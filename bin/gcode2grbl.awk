#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file gcode2grbl.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BEGIN { FS = " |\\[|]|*" }
{
    if ($1 == "G64" || $1 == "M7" || $1 == "M9") {
        printf "(%s)\n",gensub(")", "", "g")
        next;
    }
    if (substr($0, 0, 1) == "#") {
        tr[$1] = $3;
        printf "(%s)\n",gensub(")", "", "g")
        next;
    }
    printf "%s ",$1;
    for (i = 2; i <= NF; i++) {
        switch ($i) {
        case "Z#1000":
            printf "Z%s",tr["#1000"];
            break;
        case "F#1001":
            printf "F%s",tr["#1001"];
            break;
        case "Z#1002":
            printf "Z%s",tr["#1002"];
            break;
        default:
            if ($i in tr) {
                printf "%.3f",tr[$i] * $(i + 1);
                i++
                continue;
            }
            printf "%s",$i;
        }
        if (i < NF && $i != "X" && $i != "Y") {
            printf " ";
        }
    }
    printf "\n";
}
