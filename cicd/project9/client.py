#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file client.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import socket

class Client:
    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect(('localhost', 1234))
    def __del__(self):
        print('client: close')
        self.sock.close()
    def send(self, s):
        print('client: send {}'.format(s))
        self.sock.send('{}\n'.format(s).encode())
    def recv(self):
        buff = self.sock.recv(512).decode()
        print('client: recv {}'.format(buff), end='')
        return buff

client = Client()
client.send('status')
client.recv()
client.send('quit')
