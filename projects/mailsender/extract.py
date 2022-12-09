#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file extract.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import re
import os

# ---------------------------------------------------------------------------- #
## \fn readList
# ---------------------------------------------------------------------------- #
def readList(filename):
    if os.path.isfile(filename):
        with open(filename) as f:
            return f.read().splitlines()
    else:
        return list()

# ---------------------------------------------------------------------------- #
## \fn readFile
# ---------------------------------------------------------------------------- #
def readFile(filename):
    if os.path.isfile(filename):
        with open(filename) as f:
            return f.read()
    else:
        return ''

# ---------------------------------------------------------------------------- #
## \fn extract
# ---------------------------------------------------------------------------- #
def extract(dirname):
    if not os.path.isdir(dirname):
        print('{} not a directory'.format(dirname))
        sys.exit(1)

    dir = os.listdir(dirname)
    new = list()
    for filename in dir:
        with open(dirname + filename, errors='ignore') as f:
            try:
                new.extend(re.findall('([\w.-]+@[\w.-]+)', f.read()))
            except UnicodeDecodeError:
                print('UnicodeDecodeError: {0}'.format(filename))
            except Exception as e:
                print('{0}: {1}'.format(type(e), filename))
    new = [x.lower() for x in new]

    res = list()
    for str in new:
        if str.find('.') == -1:
            continue
        if re.search('^[0-9]', str):
            continue
        if re.search('\.$', str):
            continue
        if str.find('reply') != -1:
            continue
        if str.find('unsubscribe') != -1:
            continue
        if str.find('eGroups') != -1:
            continue
        if str.find('jpg@') != -1:
            continue
        if str.find('png@') != -1:
            continue
        if str.find('@phx.gbl') != -1:
            continue
        if str.find('@egroups.com') != -1:
            continue
        if re.search(str, cur):
            continue
        if re.search(str, sup):
            continue
        res.append(str)

    return res

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if len(sys.argv) != 2:
    print('Usage: {0} <dir>'.format(sys.argv[0]))
    sys.exit(1)

cur = readFile('mail-pr-.list')
sup = readFile('mail-pr-.supp')

dirname = sys.argv[1]
if os.path.isdir(dirname + '/cur/'):
    res = extract(dirname + '/cur/')
else:
    dir = os.listdir(dirname)
    res = list()
    for dirname in dir:
        res.extend(extract(sys.argv[1] + '/' + dirname + '/cur/'))

for m in sorted(set(res)):
    print(m)
