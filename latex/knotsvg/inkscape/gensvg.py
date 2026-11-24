#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file gensvg.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \brief Genere les svg Inkscape (noeud-*.svg) a partir des chemins et des
##        sodipodi:nodetypes contenus dans les fichiers noeud_*.py
##
## Usage : gensvg.py [noeud_xxx.py ...]
##         sans argument, traite tous les noeud_*.py du repertoire parent
# ---------------------------------------------------------------------------- #
import ast
import glob
import os
import re
import sys
from xml.sax.saxutils import quoteattr

_here = os.path.dirname(os.path.realpath(__file__))
_root = os.path.dirname(_here)

NODETYPES = re.compile(r'#\s*sodipodi:nodetypes\s*=\s*"([^"]*)"')

STYLE = ('fill:none;stroke:{color};stroke-width:0.1;stroke-linecap:round;'
         'stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;'
         'stroke-opacity:1')

# Couleur du premier chemin, puis des suivants
COLORS = ('#000000', '#9b0000')

HEADER = '''\
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Genere par inkscape/gensvg.py a partir de {source} -->
<svg
   width="210mm"
   height="297mm"
   viewBox="0 0 210 297"
   version="1.1"
   id="svg8"
   inkscape:version="1.2.2 (b0a8486541, 2022-12-01)"
   sodipodi:docname="{docname}"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:dc="http://purl.org/dc/elements/1.1/">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="11.180543"
     inkscape:cx="30"
     inkscape:cy="-10"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     inkscape:document-rotation="0"
     showgrid="true"
     inkscape:window-width="1920"
     inkscape:window-height="1046"
     inkscape:window-x="0"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     inkscape:showpageshadow="2"
     inkscape:pagecheckerboard="0"
     inkscape:deskcolor="#d1d1d1"
     showguides="true">
    <inkscape:grid
       type="xygrid"
       id="grid18"
       units="mm"
       spacingx="1"
       spacingy="1" />
  </sodipodi:namedview>
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Calque 1"
     inkscape:groupmode="layer"
     id="layer1">
'''

PATH = '''\
    <path
       style="{style}"
       d={d}
       id="path{n}"{nodetypes} />
'''

FOOTER = '''\
  </g>
</svg>
'''


# ---------------------------------------------------------------------------- #
## \fn read_paths
## \brief Retourne la liste des (chemin, nodetypes) du premier argument de
##        l'appel knotsvg(), les chaines vides (separateurs) etant ignorees
# ---------------------------------------------------------------------------- #
def read_paths(pyfile):
    with open(pyfile, encoding='utf-8') as f:
        source = f.read()
    lines = source.splitlines()
    for node in ast.walk(ast.parse(source, pyfile)):
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Name)
                and node.func.id == 'knotsvg' and node.args
                and isinstance(node.args[0], ast.List)):
            break
    else:
        raise ValueError('{}: appel knotsvg([...], ...) introuvable'.format(
            pyfile))
    result = list()
    for elt in node.args[0].elts:
        if not (isinstance(elt, ast.Constant) and isinstance(elt.value, str)):
            raise ValueError('{}:{}: chemin non litteral'.format(
                pyfile, elt.lineno))
        if not elt.value.strip():
            continue
        m = NODETYPES.search(lines[elt.end_lineno - 1][elt.end_col_offset:])
        if m is None:
            print('{}:{}: attention : pas de sodipodi:nodetypes'.format(
                pyfile, elt.lineno), file=sys.stderr)
        result.append((elt.value, m.group(1) if m else None))
    return result


# ---------------------------------------------------------------------------- #
## \fn write_svg
# ---------------------------------------------------------------------------- #
def write_svg(pyfile, svgfile):
    paths = read_paths(pyfile)
    out = HEADER.format(source=os.path.basename(pyfile),
                        docname=os.path.basename(svgfile))
    for n, (d, nodetypes) in enumerate(paths, 1):
        out += PATH.format(style=STYLE.format(color=COLORS[min(n, 2) - 1]),
                           d=quoteattr(d),
                           n=n,
                           nodetypes='' if nodetypes is None else
                           '\n       sodipodi:nodetypes={}'.format(
                               quoteattr(nodetypes)))
    out += FOOTER
    with open(svgfile, 'w', encoding='utf-8') as f:
        f.write(out)


# ---------------------------------------------------------------------------- #
## \fn main
# ---------------------------------------------------------------------------- #
def main():
    pyfiles = sys.argv[1:] or sorted(
        glob.glob(os.path.join(_root, 'noeud_*.py')))
    for pyfile in pyfiles:
        name = os.path.splitext(os.path.basename(pyfile))[0]
        svgfile = os.path.join(_here, name.replace('_', '-') + '.svg')
        write_svg(pyfile, svgfile)
        print(os.path.relpath(svgfile))


if __name__ == '__main__':
    main()
