#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file testHue.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
echo | awk '{
  for (x = 8; x <= 80; x += 8) {
    h = 0.5;
    for (i = 0; i < x; i++) {
      h += 0.618033988749895;
      if (h >= 1.0) {
        h -= 1.0;
      }
      print x,h;
    }
  }
}' | gnuplot -p -e 'set grid; set xtics 8; plot [0:88] "-" t ""
'
