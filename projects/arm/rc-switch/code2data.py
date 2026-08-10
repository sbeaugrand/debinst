#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file code2data.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
S1 = 24
S2 = 24
S3 = 8
LOW = S1 + S2
HIGH = S1

data = bytes.fromhex(input())
buff = []
v = 0
k = 7


def bits(n, l):
    global v
    global k
    for i in range(n):
        v |= l << k
        k -= 1
        if k < 0:
            buff.append(v)
            v = 0
            k = 7


def push(n):
    bits(n, 1)
    bits(S1 + S2 + S3 - n, 0)


push(HIGH)
for i in range(len(data)):
    for j in range(7, -1, -1):
        push(HIGH if data[i] & (1 << j) else LOW)
if k < 7:
    buff.append(v)
buff.extend([0] * (-(1000 // -150) * 7 - 12))  # delay 1 ms
# (1000 us, 150 us per bit, 7 bytes per bit, adjusted by -12 bytes for the loop)

if __name__ == "__main__":
    for v in buff:
        print(f'\\x{v:02x}', end='')
    print()
