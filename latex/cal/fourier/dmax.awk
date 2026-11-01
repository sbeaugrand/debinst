#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file dmax.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BEGIN { i = 0; m = 0; }
{
           if ($5 - $2 > m) { i = $1; m = $5 - $2;
    } else if ($2 - $5 > m) { i = $1; m = $2 - $5;
    }
}
END { printf "%05d %.2f\n",i,m; }
