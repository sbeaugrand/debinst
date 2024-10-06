#!/usr/bin/python3
# ---------------------------------------------------------------------------- #
## \file stub.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import pty
import fcntl
import os
import time
import errno


class Cancel(Exception):
    pass


class End(Exception):
    pass


# ---------------------------------------------------------------------------- #
## \class Stub
# ---------------------------------------------------------------------------- #
class Stub():

    def __init__(self):
        self.ser, self.slv = pty.openpty()
        fcntl.fcntl(self.ser, fcntl.F_SETFL,\
                    fcntl.fcntl(self.ser, fcntl.F_GETFL) | os.O_NONBLOCK)
        self.chars = []

    def __del__(self):
        os.close(self.ser)
        os.close(self.slv)

    def read(self):
        c = None
        try:
            c = os.read(self.ser, 10).decode()
        except OSError as err:
            if err.errno == errno.EAGAIN or\
               err.errno == errno.EWOULDBLOCK:
                c = None
            else:
                raise
        if c:
            self.chars.append(c)
        buf = ''.join(self.chars)
        if '\030' in buf:
            raise Cancel()
        if '\n' in buf:
            first, buf = buf.split('\n', 1)
            self.write(b'ok\n')
            if first == 'M2':
                raise End()
            if first.startswith('G1 '):
                time.sleep(0.1)
        self.chars = [buf]

    def write(self, s):
        os.write(self.ser, s)


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
stub = Stub()
print('test: {}'.format(os.ttyname(stub.slv)))
with open('pts', 'w') as f:
    f.write(os.ttyname(stub.slv))

try:
    while True:
        time.sleep(0.01)
        stub.read()
except Cancel:
    print('test: cancel')
except End:
    print('test: end')
except KeyboardInterrupt:
    pass

time.sleep(2)
os.unlink('pts')
