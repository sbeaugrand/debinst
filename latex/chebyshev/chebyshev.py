#!/usr/bin/env python
# ------------------------------------------------ #
## \file chebyshev.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://
##     fr.wikipedia.org/wiki/Filtre_de_Tchebychev
## \note Source: Design of Microwave Filters,
##     Impedance-Matching Networks, and Coupling
##     Structures, by Matthaei et. p99 https://
##     www.microwaves101.com/uploads/MYJ-part-1.pdf
# ------------------------------------------------ #
import sys
import numpy as np
import mpmath as mp

s = int(sys.argv[1])  # 1=t 2=pi
n = int(sys.argv[2])
f = float(sys.argv[3])  # MHz
rp = float(sys.argv[4])  # dbV
r1 = 50  # ohms
k = np.arange(1, n + 1)  # [1,n+1[ = [1,n]
a = np.zeros(n + 1)  # n values + a[0]
b = np.zeros(n + 1)  # n values + b[0]
g = np.zeros(n + 2)  # n+1 values + g[0]

beta = mp.log(mp.coth(rp / (40 / mp.log(10))))
gamma = mp.sinh(beta / (2 * n))
a[1:n+1] = np.sin((2 * k - 1) * np.pi / (2 * n))
b[1:n+1] = gamma ** 2 + (np.sin(k * np.pi / n)) ** 2
g[1] = 2 * a[1] / gamma
for k in np.arange(2, n + 1):
    g[k] = (4 * a[k-1] * a[k]) / (b[k-1] * g[k-1])
if n % 2 == 1:
    g[n+1] = 1
else:
    g[n+1] = mp.coth(beta / 4) ** 2
w = 2 * np.pi * f
l = r1 * g[s:n+1:2] / w
c = g[3-s:n+1:2] / (w * r1) * 1e6
r2 = r1 * g[n+1]
n = 100 * np.sqrt(l[:] / 49)
print("R1 = %.0f ohms, R2 = %.0f ohms" % (r1, r2))
sys.stdout.write("C = ")
for k in c:
    sys.stdout.write("%.0f " % k)
print("pF")
sys.stdout.write("L = ")
for k in l:
    sys.stdout.write("%.2f " % k)
print("uH")
sys.stdout.write("n = ")
for k in n:
    sys.stdout.write("%.1f " % k)
print("tours")
