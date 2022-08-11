#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 80colonnes.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Exemples :
# 80colonnes.sh
# 80colonnes.sh sh
# 80colonnes.sh tex
# 80colonnes.sh cls
# 80colonnes.sh php
# NBCOL=120 80colonnes.sh
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    ext="$1"
else
    ext="*"
fi
if [ -n "$NBCOL" ]; then
    nbcol=$NBCOL
else
    nbcol=80
fi

find . -type d -name build -prune -o -name "*.$ext" -exec awk \
'
BEGIN {
  FS = "\t";
  i = 0;
  t = 0;
}
{
  l = length($0);
  if (NF > 1) {
    l += (NF-1)*3;
    ++t;
  }
  if (l > '$nbcol') {
    ++i;
  }
}
END {
   printf "%4d %4d %s\n", i, t, FILENAME;
}
' {} \; | sort -g -r
