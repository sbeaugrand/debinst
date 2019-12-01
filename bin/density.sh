#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file density.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
density=150
if [ -n "$1" ]; then
    density=$1
fi
list=`ls *.png *.jpg 2>/dev/null`
err=0
for iter in $list; do
    if [ ! -f "$iter" ]; then
        echo "error: $iter not found"
        exit 1
    fi
    if ! identify -units PixelsPerInch -verbose $iter |\
       grep -q "Resolution: ${density}x$density"; then
        if ((err == 0)); then
            echo "Todo :" >&2
        fi
        echo "convert -units PixelsPerInch $iter -density 150 $iter" >&2
        ((err++))
    fi
done
