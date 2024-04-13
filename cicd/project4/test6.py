#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file test6.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from expect import *

r = send('status')
r.expect('"ok"')

r = send('object')
r.expect('{')
r.expect('    "status": "ok",')
r.expect('    "value": 0')
r.expect('}')

r = send('quit')
