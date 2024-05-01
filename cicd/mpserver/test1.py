#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file test1.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from time import sleep
from expect import *

r = send('rand')
r.expect('}')

r = send('ok')
r.expect('}')

sleep(1)

r = send('pause')
r.expect('}')

r = send('list')
r.expect('}')

r = send('stop')
r.expect('}')

r = send('quit')
