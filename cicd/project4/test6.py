#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file test6.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from expect import *
from wait import *

r = send('status')
r.expect('"ok"')

r = send('object')
r.expect('{')
r.expect('    "state": "not ready",')
r.expect('    "value": 0')
r.expect('}')

wait()

r = send('object')
r.expect('    "state": "ready",')

r = send('quit')
