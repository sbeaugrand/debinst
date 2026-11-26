#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file liste2page.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BEGIN { i = 2; }
{
    if (ARGC == 2) {
        n = 999;
    } else {
        n = ARGC - 2;
        i = 2;
    }
    for (; i <= n + 1; ++i) {
        if (ARGC == 2 || NR == ARGV[i]) {
            if (i % 3 == 1) {
                print $$0"\\\\";
            } else {
                print $$0"%";
            }
            if (++i > n + 1) {
                exit;
            } else {
                break;
            }
        }
    }
}
