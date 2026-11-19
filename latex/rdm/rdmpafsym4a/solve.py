#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file solve.py
## \author Sebastien Beaugrand
# ---------------------------------------------------------------------------- #
import argparse
from scipy.optimize import fsolve

parser = argparse.ArgumentParser()
parser.add_argument('-L', '--length', type=float, default=1.07)
parser.add_argument('-b', '--support', type=float, default=0.23)
args = parser.parse_args()
L = args.length
b = args.support


def f(l):
    a = (L - l) / 2 - b
    m = -(b**3 + l**3 - 2 * a**2 * b) / (2 * b + 3 * l) / 4
    e = -5 * l**4 / 384 - m * l**2 / 8
    e -= -a**4 / 8 + a * b**3 / 24 + m * a * b / 6 - a**3 * b / 6
    return e


if __name__ == '__main__':
    l = fsolve(f, 0.40)[0]
    a = (L - l) / 2 - b
    print(f'L = {L:.03f}\na = {a:.03f}\nb = {b:.03f}\nl = {l:.03f}')
    print(f'l+2b = {l+2*b:.03f}')
