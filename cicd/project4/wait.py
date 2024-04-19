#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file wait.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import json
import requests
from time import *


def wait(expression="r['state'] == 'ready'"):
    data = {
        'jsonrpc': '2.0',
        'method': 'object',
        'id': 1,
    }
    try:
        while True:
            result = requests.post(server, json=data)
            j = json.loads(result.text)
            r = j['result']
            if eval(expression):
                break
            print('wait')
            sleep(0.5)
    except:
        pass


if __name__ == '__main__':
    if len(sys.argv) > 2:
        server = sys.argv[2]
        wait(sys.argv[1])
    elif len(sys.argv) > 1:
        server = 'http://localhost:8383'
        wait(sys.argv[1])
    else:
        wait()
else:
    server = sys.argv[1]
