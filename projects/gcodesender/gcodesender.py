#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gcodesender.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://github.com/gnea/grbl/wiki
# ---------------------------------------------------------------------------- #
import serial
import time
import sys
from os import path

RX_BUFFER_SIZE = 128
BAUDRATE = 115200
dev = '/dev/ttyUSB0'

interactive = False
if len(sys.argv) > 1 and sys.argv[1] == '-i':
    interactive = True

if path.isfile('pts'):
    with open('pts') as f:
        dev = f.readline()

# ---------------------------------------------------------------------------- #
## \class CNC
# ---------------------------------------------------------------------------- #
class CNC:
    def __init__(self, dev):
        if not path.exists(dev):
            print("{} not found".format(dev))
            exit(1)
        self.ser = serial.Serial(dev, BAUDRATE)
        self.ser.write(b"\r\n\r\n")
        time.sleep(2)
        self.ser.flushInput()
        self.length = []

    def __del__(self):
        self.flush()
        self.ser.close()

    def flush(self):
        try:
            while len(self.length) > 0 or self.ser.in_waiting > 0:
                self.read()
        except OSError:
            pass

    def read(self):
        recv = self.ser.readline().decode().strip()
        if interactive:
            print(recv)
        else:
            print('recv: {}'.format(recv))
        if recv.find('ok') >= 0 or\
           recv.find('error') >= 0:
            del self.length[0]
            return 1
        return 0

    def write(self, line):
        self.length.append(len(line) + 1)
        if not interactive:
            while sum(self.length) >= RX_BUFFER_SIZE - 1 or\
                  self.ser.in_waiting > 0:
                self.read()
            print('send: {}'.format(line))
        self.ser.write(line.encode() + b'\n')

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
cnc = CNC(dev)
if not interactive:
    start = time.time()

try:
    if interactive:
        print('> ', end='', flush=True)
    for line in sys.stdin:
        line = line.strip()
        if len(line) == 0 or line[0] == '(':
            if interactive:
                print('> ', end='', flush=True)
            continue
        cnc.write(line)
        if interactive:
            while cnc.read() == 0:
                pass
            print('> ', end='', flush=True)
except KeyboardInterrupt:
    cnc.ser.write(b'\030')
    time.sleep(1)
    cnc.ser.write(b'?')
    time.sleep(1)

if not interactive:
    cnc.flush()
    h, r = divmod(time.time() - start, 3600)
    m, s = divmod(r, 60)
    print('time: {}h{}m{}s'.format(int(h), int(m), int(s)))
    try:
        while True:
            time.sleep(0.1)
    except KeyboardInterrupt:
        pass
