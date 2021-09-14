#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file uniq.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys

mlist = sys.stdin.read().splitlines()
res = list()

for mel in mlist:
    found = False
    for str in mlist:
        if str.find(mel) != -1 and str != mel:
            found = True
            break
    if not found:
        if mel not in res:
            res.append(mel)
            print(mel)
