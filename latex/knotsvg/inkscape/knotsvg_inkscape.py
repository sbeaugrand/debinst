#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file knotsvg_inkscape.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \brief Extension Inkscape : dessine un noeud a partir des chemins
##        selectionnes, avec la geometrie de knotsvg.py
# ---------------------------------------------------------------------------- #
import os
import re
import sys

import inkex
from inkex import ClipPath, Group, PathElement, TextElement, Transform

# knotsvg.py est cherche a cote de l'extension (copie installee) puis dans
# le repertoire parent (depot, eventuellement via un lien symbolique)
_here = os.path.dirname(os.path.realpath(__file__))
sys.path[:0] = [_here, os.path.dirname(_here)]
from knotsvg import (Strand, clip_offsets, layers, parse_numbers, scale,
                     strand_angle)


# ---------------------------------------------------------------------------- #
## \class KnotSvg
# ---------------------------------------------------------------------------- #
class KnotSvg(inkex.EffectExtension):
    def add_arguments(self, pars):
        pars.add_argument("--tab")
        pars.add_argument("--depth", default="")
        pars.add_argument("--xscale", type=float, default=1.0)
        pars.add_argument("--yscale", type=float, default=1.0)
        pars.add_argument("--unit", type=float, default=1.0)
        pars.add_argument("--title", default="")
        pars.add_argument("--title_insert", default="0,0")
        pars.add_argument("--strands", default="")
        pars.add_argument("--show_index", type=inkex.Boolean, default=False)

    def effect(self):
        opt = self.options
        elems = self.svg.selection.filter(PathElement).rendering_order()
        if not elems:
            raise inkex.AbortExtension("Sélectionnez au moins un chemin.")

        # Chemins en coordonnees du document. Une unite knotsvg (opt.unit
        # unites du document) vaut scale unites internes, comme dans
        # knotsvg.py ; le groupe produit est ensuite reduit d'autant pour
        # retomber sur le dessin. xscale et yscale s'appliquent depuis
        # l'origine, comme dans knotsvg.py.
        paths = [
            e.path.to_absolute().transform(e.composed_transform())
            for e in elems
        ]
        kx = scale / opt.unit * opt.xscale
        ky = scale / opt.unit * opt.yscale

        # Sens des torons : un signe par chemin (+ par defaut), equivalent
        # de l'alternance de knotsvg.py ou chaque element de la liste, meme
        # une chaine vide '', inverse le sens
        signs = re.findall(r'[-+]', opt.strands)
        curves = list()
        for n, p in enumerate(paths):
            sign = signs[n] if n < len(signs) else '+'
            angle = strand_angle if sign == '+' else -strand_angle
            for sub in p.to_superpath():
                xlist = list()
                ylist = list()
                for j, node in enumerate(sub):
                    pts = [sub[j - 1][2], node[0], node[1]] if j else [node[1]]
                    for x, y in pts:
                        xlist.append(x * kx)
                        ylist.append(y * ky)
                curves += Strand(angle).compute_path(xlist, ylist)

        depth = parse_numbers(opt.depth)
        if len(depth) != len(curves):
            inkex.errormsg(
                "Le noeud comporte {} segments mais depth contient {} valeurs"
                " (les valeurs manquantes valent 1).".format(
                    len(curves), len(depth)))
        missing = len(curves) - len(depth)
        depth = depth[:len(curves)] + [1] * max(0, missing)

        layer = self.svg.get_current_layer()
        group = Group()
        group.label = "knotsvg"
        group.transform = -layer.composed_transform() @ Transform(
            scale=opt.unit / scale)
        layer.add(group)
        self.__trace(group, curves, depth)
        self.__trace_titles(group)
        if opt.show_index:
            self.__trace_index(group, curves, depth, missing)

    def __trace(self, group, curves, depth):
        lower, upper, shadow, clip = layers(curves, depth)
        cp = ClipPath(id=self.svg.get_unique_id("knotsvg_clip"))
        self.svg.defs.add(cp)
        for d in clip:
            for dx, dy in clip_offsets:
                cp.add(
                    PathElement(d=d,
                                transform=str(
                                    Transform(translate=(dx * scale,
                                                         dy * scale)))))
        groups = list()
        for label, paths in (("dessous", lower), ("ombre", shadow),
                             ("dessus", upper)):
            g = Group()
            g.label = label
            for d in paths:
                g.add(PathElement(d=d))
            groups.append(g)
        style = {'fill': 'white', 'stroke': 'black', 'stroke-width': 0.02 * scale}
        groups[0].style = style
        groups[2].style = style
        groups[1].style = {'fill': 'black', 'stroke': 'none'}
        groups[1].set('clip-path', 'url(#{})'.format(cp.get_id()))
        group.add(*groups)

    def __trace_titles(self, group):
        if not self.options.title:
            return
        lines = self.options.title.split('|')
        nums = parse_numbers(self.options.title_insert)
        inserts = [(nums[i], nums[i + 1]) for i in range(0, len(nums) - 1, 2)]
        if not inserts:
            inserts = [(0, 0)]
        for i, line in enumerate(lines):
            if i < len(inserts):
                x, y = inserts[i]
            else:
                x, y = inserts[-1][0], inserts[-1][1] + i - len(inserts) + 1
            text = TextElement(x=str(x * scale), y=str(y * scale))
            text.text = line
            text.style = 'font-size:5px; font-family:Arial'
            group.add(text)

    def __trace_index(self, group, curves, depth, missing):
        labels = Group()
        labels.label = "numéros"
        labels.style = {
            'font-size': '4px',
            'font-family': 'Arial',
            'font-weight': 'bold',
            'text-anchor': 'middle'
        }
        first_missing = len(curves) - missing
        for j, (_, (x, y)) in enumerate(curves):
            text = TextElement(x=str(x), y=str(y))
            text.text = str(j + 1)
            if j >= first_missing:
                color = 'gray'
            else:
                color = 'blue' if depth[j] >= 0 else 'red'
            text.style = {'fill': color}
            labels.add(text)
        group.add(labels)


if __name__ == '__main__':
    KnotSvg().run()
