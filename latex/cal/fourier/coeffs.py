#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file coeffs.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import numpy as np
import sys

data = np.loadtxt(sys.argv[1], dtype=float)
days = data[:, 0]
mins = data[:, 1]
w = 2 * np.pi / 365.2425
x = np.column_stack([
    np.ones_like(days),
    np.cos(w * days),
    np.sin(w * days),
    np.cos(2 * w * days),
    np.sin(2 * w * days),
    np.cos(3 * w * days),
    np.sin(3 * w * days)
])
coeffs, *_ = np.linalg.lstsq(x, mins, rcond=None)
a0, a1, b1, a2, b2, a3, b3 = [round(x, 2) for x in coeffs]
print(f'{a0} {a1} {b1} {a2} {b2} {a3} {b3}')
