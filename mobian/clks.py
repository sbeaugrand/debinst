#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file clks.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import json
import sys

DAYS = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')

for p in json.load(sys.stdin):
    if p['active']:
        days = ','.join([DAYS[d] for d in p['days']])
        h = p['hour']
        m = p['minute'] - 1
        if m < 0:
            m = 59
            h -= 1
        print('# {}'.format(p['name']))
        print('OnCalendar={} {:02d}:{:02d}:55'.format(days, h, m))
