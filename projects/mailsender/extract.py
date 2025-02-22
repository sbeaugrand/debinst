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
## \fn read_list
# ---------------------------------------------------------------------------- #
def read_list(filename):
    if os.path.isfile(filename):
        with open(filename) as f:
            return f.read().splitlines()
    else:
        return list()


# ---------------------------------------------------------------------------- #
## \fn read_file
# ---------------------------------------------------------------------------- #
def read_file(filename):
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
        print(f'{dirname} not a directory')
        sys.exit(1)

    dir = os.listdir(dirname)
    new = list()
    for filename in dir:
        with open(dirname + filename, errors='ignore') as f:
            try:
                new.extend(
                    re.findall('([\w\.\-]+@[\w\.\-]+)',
                               f.read().replace('=\n', '')))
            except UnicodeDecodeError:
                print(f'UnicodeDecodeError: {filename}')
            except Exception as e:
                print(f'{type(e)}: {filename}')
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
        if str.find('@mail.gmail.com') != -1:
            continue
        if re.search('@.*\.prod\.', str):
            continue
        if re.search(str, cur):
            continue
        if re.search('\n' + str, sup):
            continue
        res.append(str)

    return res


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if len(sys.argv) != 2:
    print(f'Usage: {sys.argv[0]} <directory>')
    sys.exit(1)

cur = read_file('mail-pr-.list')
sup = read_file('mail-pr-.supp')

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
