#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file vacances.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import json
from datetime import datetime, timedelta

N_RECORDS = 18

if len(sys.argv) != 2:
    print('Usage: {} <year>'.format(sys.argv[0]))
    exit(1)
year = int(sys.argv[1])

with open('vacances{}.json'.format(year), 'r') as f:
    data = json.load(f)
n = len(data['records'])
if n != N_RECORDS:
    print('error: {} records != {}'.format(n, N_RECORDS))
    exit(1)

i = 0
for r in data['records']:
    start = datetime.fromisoformat(
        r['fields']['start_date'])
    if start.weekday() == 4:
        start += timedelta(days=2)
    else:
        start += timedelta(days=1)
    end = datetime.fromisoformat(r['fields']['end_date'])
    zone = r['fields']['zones'].replace(' ', '')
    if start.year < year:
        start = datetime(year, 1, 1)
    if end.year > year:
        end = datetime(year, 12, 31)
    sv = chr(ord('A') + i // 3)
    print('    v{}sm{}={:02}; v{}sd{}={:02}; v{}em{}={:02}; v{}ed{}={:02};'.
          format(sv, zone, start.month, sv, zone, start.day, sv, zone,
                 end.month, sv, zone, end.day))
    if i % 3 == 2:
        print()
    i += 1
