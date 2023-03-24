#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file grblsimplify.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <filename.ngc>"
    exit 1
fi

awk '
BEGIN { FS = " X| Y"; x = -1; y = -1 }
{
    switch ($1) {
    case " G01":
    case "G01":
        x = $2;
        y = $3;
        print $0;
        break;
    case "G00":
        dx = $2 - x;
        dy = $3 - y;
        if (dx < 0) {
            dx = -dx;
        }
        if (dy < 0) {
            dy = -dy;
        }
        if (dx > 0.002 || dy > 0.002) {
            print $0;
        }
        x = -1;
        y = -1;
        break;
    default:
        print $0;
    }
}' $1 | awk '
BEGIN { prec = "" }
{
    if (substr(prec, 0, 5) == "G00 Z" && substr($0, 0, 5) == "G00 Z") {
        prec = "";
    } else {
        if (prec != "") {
            print prec;
        }
        prec = $0;
    }
}
END { if (prec != "") print prec }'
