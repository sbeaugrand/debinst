#!/bin/awk -f
# ---------------------------------------------------------------------------- #
## \file result.awk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
{
    a0 = $1;
    a1 = $2;
    b1 = $3;
    a2 = $4;
    b2 = $5;
    a3 = $6;
    b3 = $7;
    w = 2 * 3.14159 / 365.2425;
    n = 365 * NYEAR;
    for (d = 1; d <= n; ++d) {
        print d,a0\
            + a1*cos(  w*d) + b1*sin(  w*d)\
            + a2*cos(2*w*d) + b2*sin(2*w*d)\
            + a3*cos(3*w*d) + b3*sin(3*w*d)\
        ;
    }
}
