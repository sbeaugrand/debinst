#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file ips.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import re

t = {}
with open('/var/log/iptraf.{}'.format(sys.argv[1])) as f:
    for line in f:
        s = line.split(';')
        if len(s) <= 6:
            continue
        k = re.sub(':[0-9]*', '', s[4].rstrip())
        t[k] = t.get(k, 0) + int(s[6].split(',')[1].split()[0])

for k, v in t.items():
    print('{0}: {1} k'.format(k[6:], v // 1000))
