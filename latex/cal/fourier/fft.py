#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file fft.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import matplotlib.pyplot as pyplot
import numpy as np
import sys

sr = 365.25
data = np.loadtxt(sys.argv[1], dtype=float)
X = np.fft.fft(data[:, 1])
N = len(X)
n = np.arange(N)
T = N / sr
freq = n / T

l = 7
x = freq[1:int(l * T)]
y = np.abs(X)[1:int(l * T)]
for i in range(1, l):
    print(f'{i}w {y[i * int(T) - 1]:9.2f}')

pyplot.stem(x, y, markerfmt='+')
pyplot.show()
