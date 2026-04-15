#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file client.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import socket
from time import time

factor = 3.3 / (1 << 12)

sock = socket.socket(type=socket.SOCK_DGRAM)
sock.settimeout(1)
sock.sendto(b'coucou', ('192.168.1.200', 1000))

try:
    for i in range(10):
        start = time()
        data, _ = sock.recvfrom(512)
        if (data[1] & 0xf0):
            shift0 = 8
            shift1 = 0
        elif (data[0] & 0xf0):
            shift0 = 0
            shift1 = 8
        print('{:02x}{:02x}  {:.3f}V {:5d}Hz'.format(
            data[0], data[1],
            ((data[0] << shift0) + (data[1] << shift1)) * factor,
            int(256 / (time() - start))))
except socket.timeout:
    print('error: timeout')
