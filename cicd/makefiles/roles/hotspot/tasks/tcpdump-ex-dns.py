#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file tcpdump-ex-dns.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
for line in sys.stdin:
    line = line.strip()
    fields = line.split()
    if len(fields) <= 7 or fields[0][0] not in '012':
        if len(line) > 0:
            print(line)
        continue
    url = fields[7]
    ip = fields[2]
    match ip[0:11]:
        case '10.66.0.123': ip = 'Papa  '
        case '10.66.0.11.': ip = 'Papi  '
        case '10.66.0.111': ip = 'Papo  '
    print(f'{ip} {url}')
