#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file reduce.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BEGIN {
    p = 1;
} {
    if (p) {
        print $0;
        if ($4 == "Z1.000000") {
            p = 0;
        }
    } else if ($4 != "Z1.000000") {
        print l;
        print $0;
        p = 1;
    } else {
        l = $0;
    }
}
