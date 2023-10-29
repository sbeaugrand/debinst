#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file faces2edges.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
import argparse
from os import path

parser = argparse.ArgumentParser()
parser.add_argument('-f',
                    '--file',
                    default=sys.stdin,
                    type=argparse.FileType('r'))
args = parser.parse_args()


# ---------------------------------------------------------------------------- #
## \fn points
# ---------------------------------------------------------------------------- #
def points(line):
    pos = line.find('points="') + len('points="')
    end = line.find('"', pos)
    return line[pos:end].split()


# ---------------------------------------------------------------------------- #
## \fn color
# ---------------------------------------------------------------------------- #
def color(line):
    pos = line.find('fill="') + len('fill="')
    end = line.find('"', pos)
    return line[pos:end].split()


# ---------------------------------------------------------------------------- #
## \fn tri2quadri
# ---------------------------------------------------------------------------- #
def tri2quadri(line1, line2):
    if color(line1) != color(line2):
        return False
    t1 = points(line1)
    t2 = points(line2)
    links = []
    if t2[0] == t1[0]:
        links.append((0, 0))
    elif t2[0] == t1[1]:
        links.append((1, 0))
    elif t2[0] == t1[2]:
        links.append((2, 0))
    if t2[1] == t1[0]:
        links.append((0, 1))
    elif t2[1] == t1[1]:
        links.append((1, 1))
    elif t2[1] == t1[2]:
        links.append((2, 1))
    if t2[2] == t1[0]:
        links.append((0, 2))
    elif t2[2] == t1[1]:
        links.append((1, 2))
    elif t2[2] == t1[2]:
        links.append((2, 2))
    if len(links) != 2:
        return False
    p1 = t1[0]
    p2 = t1[1]
    p3 = t1[2]
    p4 = t2[3 - links[0][1] - links[1][1]]
    if links[0][0] + links[1][0] == 1:
        p = p2
        p2 = p3
        p3 = p
    elif links[0][0] + links[1][0] == 3:
        p = p3
        p3 = p4
        p4 = p
    print('<polygon fill="white" stroke="black" stroke-width="2"'
          ' points="{} {} {} {}"/>'.format(p1, p2, p3, p4))
    return True


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
lines = []
for line in args.file:
    if 'shape-rendering' not in line:
        if '</g>' in line or '</svg>' in line:
            continue
        print(line.replace('fill="#000000"', 'fill="white"'), end='')
    else:
        lines.append(line)

n = len(lines)
prec = None
errors = 0
for i in range(0, n):
    line = lines[i]
    if prec is None:
        prec = line
        continue
    found = False
    #for j in range(i, n):
    for j in range(i, i + 1):
        if tri2quadri(prec, lines[j]):
            found = True
            prec = None
            break
    if not found:
        errors += 1
        pos = prec.find('points="') + len('points="')
        end = prec.find('"', pos)
        print('<polygon fill="white" stroke="black" stroke-width="2"'
              ' points="{}"/>'.format(prec[pos:end]))
        prec = line

print('</g>')
print('</svg>')

if errors > 0:
    print('errors: {}'.format(errors), file=sys.stderr)
