#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gramps2tex.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import csv
import os
import re
import sys
from datetime import date

from randomColor import RandomColor, fmt

GENRE_M = 1
GENRE_F = 2
LIEU = 1
INDIVIDU = 2
MARIAGE = 3
FAMILLE = 4

out = sys.stdout.write


def col(d, i):
    """Champ i d'une ligne CSV ('' si absent)."""
    if d is None or i >= len(d):
        return ''
    return d[i]


def num(s):
    """Nombre à partir d'un argument (int si entier)."""
    x = float(s)
    return int(x) if x.is_integer() else x


def div(a, b):
    """Division à la PHP : int si le résultat est entier."""
    x = a / b
    return int(x) if x.is_integer() else x


def isNumeric(s):
    return re.fullmatch(r'\s*[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?\s*',
                        s) is not None


def parseDate(s):
    m = re.fullmatch(r'(\d{4})-(\d{1,2})(?:-(\d{1,2}))?', s)
    if m is None:
        raise ValueError(f'date invalide: {s}')
    return date(int(m[1]), int(m[2]), int(m[3] or 1))


def yearsDiff(d1, d2):
    if d2 < d1:
        d1, d2 = d2, d1
    y = d2.year - d1.year
    if (d2.month, d2.day) < (d1.month, d1.day):
        y -= 1
    return y


# ---------------------------------------------------------------------------- #
## \class Departement
# ---------------------------------------------------------------------------- #
class Departement:

    def __init__(self, d):
        self.name = d
        self.color = ''


# ---------------------------------------------------------------------------- #
## \class DepartementList
# ---------------------------------------------------------------------------- #
class DepartementList:

    def __init__(self):
        self.randomColor = RandomColor(0.45)
        self.deparList = []

    def add(self, d):
        self.deparList.append(Departement(d))

    def getColor(self, d):
        for dep in self.deparList:
            if dep.name != d:
                continue
            if not dep.color:
                dep.color = self.addColor(d)
            return self.colorName(d)
        return ''

    def addColor(self, d):
        c = self.colorName(d)
        r, g, b = self.randomColor.nextRgb(0.24, 0.99)
        out(f'\\definecolor{{{c}{GENRE_M}}}{{rgb}}'
            f'{{{fmt(r)},{fmt(g)},{fmt(b)}}}\n')
        r, g, b = self.randomColor.rgb(0.12, 0.99)
        out(f'\\definecolor{{{c}{GENRE_F}}}{{rgb}}'
            f'{{{fmt(r)},{fmt(g)},{fmt(b)}}}\n')
        return c

    @staticmethod
    def colorName(d):
        for a, b in (('-', ''), ("'", ''), ('è', 'e'), ('ô', 'o')):
            d = d.replace(a, b)
        return d


# ---------------------------------------------------------------------------- #
## \class Individu
# ---------------------------------------------------------------------------- #
class Individu:

    def __init__(self, i, lieu=None, departement=None):
        lieu = lieu or {}
        departement = departement or {}
        self.nom = re.sub('[a-z]+', lambda m: m[0].upper(), col(i, 1))
        self.prenom = col(i, 2)
        self.dateNaissance = col(i, 8)
        self.dateMort = col(i, 14)
        self.villeNaissance = ''
        self.depNaissance = None
        self.villeMort = ''
        if col(i, 9) in lieu:
            self.villeNaissance = lieu[col(i, 9)]
            self.depNaissance = departement.get(col(i, 9))
        if col(i, 15) in lieu:
            self.villeMort = lieu[col(i, 15)]
        self.titre = col(i, 6)
        self.label = col(i, 0).replace('[', '').replace(']', '')

    def getColor(self, genre, departementList):
        if self.depNaissance:
            return f'={departementList.getColor(self.depNaissance)}{genre}'
        return ''

    def print(self, niveau):
        out('{\\begin{tabular}{@{}l@{}}')
        out(f'{self.nom} {self.prenom}')
        out(f'\\\\{self.dateNaissance}~{self.villeNaissance}'
            f'\\\\{self.dateMort}~{self.villeMort}')
        if niveau < 7:
            out(f'\\\\{self.age()}{self.titre}')
        for ext in ('png', 'jpg'):
            if os.path.exists(f'build/{self.label}.{ext}'):
                out(f'\\\\\\includegraphics{{build/{self.label}.{ext}}}')
                break
        out('\\end{tabular}}\n')

    def age(self):
        if not self.dateMort or not self.dateNaissance:
            return ''
        a1 = self.dateNaissance[:4]
        a2 = self.dateMort[:4]
        if not isNumeric(a1) or not isNumeric(a2):
            return ''
        f1 = self.dateNaissance[:10]
        f2 = self.dateMort[:10]
        if (len(f1) <= 4 or f1[4] != '-' or len(f2) <= 4 or f2[4] != '-'):
            return f'{int(float(a2)) - int(float(a1))} ans '
        return f'{yearsDiff(parseDate(f1), parseDate(f2))} ans '


# ---------------------------------------------------------------------------- #
## \class Arbre
# ---------------------------------------------------------------------------- #
class Arbre:

    def __init__(self, lmax, below, left, right):
        self.lieu = {}
        self.departement = {}
        self.departementList = None
        self.individus = {}
        self.mariage = {}
        self.famille = {}
        self.niveau = 0
        self.anneeMariage = None
        self.villeMariage = ''
        self.pass1 = 0
        self.pass2 = 0
        self.lmax = lmax
        self.below = below
        self.left = left
        self.right = right
        self.parent = 1
        self.sens = -1
        self.offsetNode = 0
        self.offsetDate = 0

    def init(self, parent):
        self.parent = parent
        self.sens = -1 if self.parent == 1 else 1
        self.offsetNode = -26.6 * self.sens
        self.offsetDate = -26.6 * self.sens

    def readCSV(self, filename):
        self.departementList = DepartementList()
        table = 0
        tmpDepartement = {}
        with open(filename, newline='', encoding='utf-8') as f:
            for d in csv.reader(f):
                if not col(d, 0):
                    continue
                t = d[0].strip()
                if t == 'Lieu':
                    table = LIEU
                elif t == 'Individu':
                    table = INDIVIDU
                elif t == 'Mariage':
                    table = MARIAGE
                elif t == 'Famille':
                    table = FAMILLE
                elif table == LIEU:
                    if col(d, 3) == 'Département':
                        self.departementList.add(col(d, 2))
                        tmpDepartement[d[0]] = col(d, 2)
                    else:
                        self.lieu[d[0]] = col(d, 2)
                        self.departement[d[0]] = \
                            tmpDepartement.get(col(d, 7))
                elif table == INDIVIDU:
                    self.individus[d[0]] = \
                        Individu(d, self.lieu, self.departement)
                elif table == MARIAGE:
                    self.mariage[d[0]] = d
                elif table == FAMILLE:
                    self.famille[col(d, 1)] = d[0]

    def getFirstNodeParent(self, parent):
        return col(next(iter(self.mariage.values())), parent)

    def mariageDe(self, n):
        return self.mariage.get(self.famille.get(n))

    def printNode(self, n, genre):
        if not n:
            return
        i = self.individus[n]
        out(' ' * self.niveau)
        out('\\' if self.niveau == 0 else 'child{ ')
        couleur = i.getColor(genre, self.departementList)
        out(f'node [individu{couleur}] ')
        out(f'({i.label}) ')
        if self.niveau == 4:
            offsetX = 3.5 * self.sens
            out(f'at ({fmt(offsetX)},{fmt(self.offsetNode)}) ')
            if self.pass1 == 1:
                self.offsetNode += 7.2 * self.sens
                if self.pass2 == 1:
                    self.offsetNode += 0.9 * self.sens
                self.pass2 = 1 - self.pass2
            self.pass1 = 1 - self.pass1
        i.print(self.niveau)
        if self.niveau == 0 and self.anneeMariage is None:
            m = self.mariageDe(n)
            self.anneeMariage = col(m, 3) if m is not None else None
            self.villeMariage = self.lieu.get(col(m, 4), '')
        self.niveau += 1
        if self.niveau < self.lmax:
            self.printParents(n)
        self.niveau -= 1
        out(' ' * self.niveau)
        if 0 < self.niveau < self.lmax - 1 and self.famille.get(n):
            m = self.mariageDe(n)
            if self.niveau > 5:
                s = col(m, 3)
                if s[:6] == 'avant ':
                    s = 'av. ' + s[6:10]
                else:
                    s = s[:4]
            else:
                s = col(m, 3) + ' ' + self.lieu.get(col(m, 4), '')
            out('edge from parent node[')
            # left
            out('left' if self.sens < 0 else 'right')
            delta = {4: 50, 2: 5, 1: 5}.get(self.niveau, 0)
            out(f'={fmt(self.left + delta)}mm')
            # above
            if self.niveau == 4:
                out(f',above={fmt(self.offsetDate)}cm')
                if self.pass1 == 0:
                    self.offsetDate += 7.2 * self.sens
                    if self.pass2 == 0:
                        self.offsetDate += 0.9 * self.sens
            out(f']{{{s}}}')
        if self.niveau == 1 and self.anneeMariage is not None:
            out('edge from parent node[')
            out(f'above={fmt(self.below)}mm,')
            out(f'left={fmt(-30 * self.sens)}mm')
            out(f']{{{self.anneeMariage} {self.villeMariage}}}')
            self.anneeMariage = None
        out(';\n' if self.niveau == 0 else '}\n')

    def parents(self, n):
        if n not in self.famille:
            return []
        m = self.mariageDe(n)
        pere = (col(m, 1), GENRE_M)
        mere = (col(m, 2), GENRE_F)
        return [pere, mere] if self.parent == 1 else [mere, pere]

    def printParents(self, n):
        for p, g in self.parents(n):
            self.printNode(p, g)

    def browseNode(self, n, genre):
        if not n:
            return
        self.individus[n].getColor(genre, self.departementList)
        self.niveau += 1
        if self.niveau < self.lmax:
            for p, g in self.parents(n):
                self.browseNode(p, g)
        self.niveau -= 1


# ---------------------------------------------------------------------------- #
## \fn tests
# ---------------------------------------------------------------------------- #
def tests():

    def testAge(n, m, a):
        i = Individu(
            ['', '', '', '', '', '', '', '', n, '', '', '', '', '', m, ''])
        age = i.age()
        if age != f'{a} ans ':
            print(f'error: age {age}({n}, {m}, {a})')
            sys.exit(1)

    testAge('2000-02-02', '2001-02-02', 1)
    testAge('2000-02-02', '2001-02-01', 0)
    testAge('2000-02-02', '2001-01-02', 0)
    testAge('2000-02-02', '2001', 1)
    testAge('2000', '2001-12-31', 1)
    print('OK')


# ---------------------------------------------------------------------------- #
## \fn main
# ---------------------------------------------------------------------------- #
def main(argv):
    if len(argv) == 2 and argv[1] == 'tests':
        tests()
        return
    if len(argv) != 6:
        print(f'Usage: {argv[0]} <export.csv> (1 | 2) <lmax>'
              ' <sibiling-distance> <level-distance>')
        sys.exit(1)
    filename = argv[1]
    parent = int(argv[2])
    lmax = num(argv[3])
    below = div(num(argv[4]), 4)
    left = div(num(argv[5]), 2) + 2
    right = div(num(argv[5]), 2) - 5

    a = Arbre(lmax, below, left, right)
    a.readCSV(filename)
    a.init(1)
    a.browseNode(a.getFirstNodeParent(1), GENRE_M)
    a.init(2)
    a.browseNode(a.getFirstNodeParent(2), GENRE_F)
    a.init(parent)
    print(f'Lieux: {len(a.lieu)}', file=sys.stderr)
    print(f'Individus: {len(a.individus)}', file=sys.stderr)
    print(f'Mariages: {len(a.mariage)}', file=sys.stderr)
    print(f'Familles: {len(a.famille)}', file=sys.stderr)
    genre = GENRE_M if parent == 1 else GENRE_F
    a.printNode(a.getFirstNodeParent(parent), genre)


if __name__ == '__main__':
    main(sys.argv)
