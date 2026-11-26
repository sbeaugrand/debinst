#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file testRGB.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from randomColor import RandomColor, fmt

print(r'''
\documentclass[a4paper]{article}
\pagestyle{empty}
\usepackage{vmargin}
\setmarginsrb{10mm}{10mm}{10mm}{10mm}{0mm}{0mm}{0mm}{0mm}
\usepackage{tikz}
\parindent0mm
\begin{document}
  \tiny
  \begin{tikzpicture}''')

rc = RandomColor(0.45)
for j in range(12, -1, -1):
    for i in range(8):
        hue = rc.hue
        r, g, b = rc.nextRgb(0.24, 0.99)
        color = f'color{i}y{j}'
        print(f'\\definecolor{{{color}}}{{rgb}}{{{fmt(r)},{fmt(g)},{fmt(b)}}}')
        x = i * 2
        y = j * 2
        print(f'\\fill[{color}, draw=black,thick,rounded corners=3pt] '
              f'({x},{y}) -- ({x + 1},{y}) -- ({x + 1},{y + 1}) -- '
              f'({x},{y + 1}) -- cycle node[black,below] {{{fmt(hue)}}};')

print(r'\end{tikzpicture}')
print(r'\newline\newline')
for k, name in enumerate(('Rouge', 'Jaune', 'Vert', 'Cyan', 'Bleu', 'Violet')):
    rc = RandomColor(k / 6)
    r, g, b = rc.rgb(1.0, 1.0)
    print(f'Hue {k}.0/6 = {name} ({fmt(r)} {fmt(g)} {fmt(b)})\\newline')
print(r'\end{document}')
