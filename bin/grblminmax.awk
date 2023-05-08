#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file grblminmax.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BEGIN {
    FS = " X| Y";
    xmin = 1000;
    ymin = 1000;
    xmax = -1;
    ymax = -1;
    unit = 1;
} {
    switch ($1) {
    case " G01":
    case "G01":
    case "G00":
        x = $2;
        y = $3;
        if (xmin > x) {
            xmin = x;
        }
        if (xmax < x) {
            xmax = x;
        }
        if (ymin > y) {
            ymin = y;
        }
        if (ymax < y) {
            ymax = y;
        }
        break;
    default:
        if (substr($1, 0, 3) == "G20") {
            unit = 25.4;
        }
        break;
    }
}
END {
    print xmin * unit, ymin * unit, xmax * unit, ymax * unit;
}
