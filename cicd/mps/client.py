#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file client.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import json
import requests

if len(sys.argv) > 2:
    server = sys.argv[1]
    method = sys.argv[2]
elif len(sys.argv) > 1:
    server = 'http://localhost:8383'
    method = sys.argv[1]
else:
    server = 'http://localhost:8383'
    method = 'info'

data = {
    'jsonrpc': '2.0',
    'method': method,
}
if method != 'quit':
    data['id'] = 1

try:
    result = requests.post(server, json=data)
    j = json.loads(result.text)
    if method != 'quit':
        print(json.dumps(j['result'], indent=4))
except:
    pass
