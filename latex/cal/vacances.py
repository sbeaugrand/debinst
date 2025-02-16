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
    print(f'Usage: {sys.argv[0]} <year>')
    exit(1)
year = int(sys.argv[1])

with open(f'vacances{year}.json', 'r') as f:
    data = json.load(f)
n = len(data['records'])
if n != N_RECORDS:
    print(f'error: {n} records != {N_RECORDS}')
    exit(1)

i = 0
for r in data['records']:
    start = datetime.fromisoformat(r['fields']['start_date'])
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
    print(f'   '
          f' v{sv}sm{zone}={start.month:02};'
          f' v{sv}sd{zone}={start.day:02};'
          f' v{sv}em{zone}={end.month:02};'
          f' v{sv}ed{zone}={end.day:02};')
    if i % 3 == 2:
        print()
    i += 1
