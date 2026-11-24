# knotsvg

Dessin de nœuds de corde en SVG, avec torons et ombres aux croisements, et
assemblage en livret PDF.

## Livret PDF
```sh
sudo apt install python3-svgwrite inkscape texlive-latex-base pdfjam
make             # knotsvg.pdf
make landscape   # landscape.pdf : 2 pages côte à côte
make vertical    # vertical.pdf : 2 pages l'une au-dessus de l'autre
make build/noeud_plat.svg   # un seul nœud
```
Chaque `noeud_*.py` produit `build/noeud_*.svg`, converti en PDF par
Inkscape puis inclus dans `knotsvg.tex`.

## Décrire un nœud
```python
from knotsvg import *
knotsvg(
    ['M 0,-4 C 2,-4 2,-3 4,-3 5,-3 5,-4 6,-4 7,-4 8,-3 8,-2 8,-1 7,0 6,0 5,0 5,-1 4,-1 2,-1 2,0 0,0', '',
     'M 10,-4 C 8,-4 8,-3 6,-3 5,-3 5,-4 4,-4 3,-4 2,-3 2,-2 2,-1 3,0 4,0 5,0 5,-1 6,-1 8,-1 8,0 10,0'],
    [1, -1, 1, 1, -1, 1, -1, 1, -1, -1, 1, -1], xscale=1.0, yscale=0.8, title='Nœud plat', title_insert=(3.8,-1.5))
```
- `paths` : liste de chemins SVG composés uniquement de `M`/`m` et
  `C`/`c` (Bézier cubiques). Chaque élément de la liste, **y compris une
  chaîne vide `''`**, inverse le sens des torons : `['A', '', 'B']` donne
  deux brins de même sens, `['A', 'B']` deux sens opposés.
- `depth` : une valeur par segment de Bézier, dans l'ordre des chemins :
  positive = brin au-dessus, négative = brin en dessous.
- `xscale`, `yscale` : échelles appliquées depuis l'origine.
- `title`, `title_insert` : texte (ou liste de lignes) et position(s), en
  unités des chemins.

Un toron fait 0,5 unité de large ; la page fait 20 × 12 unités
(x de 0 à 20, y de -11 à 1).

## Extension Inkscape
Permet de dessiner les chemins à la souris dans Inkscape puis de générer le
nœud (menu *Extensions › Render › Nœud (knotsvg)*).
```sh
make inkscape    # liens symboliques dans ~/.config/inkscape/extensions
```
Redémarrer Inkscape après l'installation ou une modification du `.inx`.

Les paramètres sont ceux de `knotsvg.py`, plus :
- **Sens des torons** : un signe `+` ou `-` par chemin sélectionné, dans
  l'ordre d'empilement (nœud plat : `+ +`, nœud de pêcheur : `+ -`).
- **Unité knotsvg** : longueur du document correspondant à une unité des
  chemins (1 = mêmes coordonnées que les `noeud_*.py`).
- **Afficher les numéros de segments** : aide à remplir `depth`
  (bleu = dessus, rouge = dessous, gris = valeur manquante).

### Tester l'extension
Les fichiers de test ne sont pas dans le dépôt, il faut d'abord les générer :
```sh
make svg         # inkscape/noeud-*.svg à partir des noeud_*.py
```
Chaque `inkscape/noeud-*.svg` contient les chemins du `noeud_*.py`
correspondant (le deuxième chemin éventuel en rouge). Pour tester
l'extension : ouvrir le fichier,
sélectionner tous les chemins et reprendre `depth`, `xscale`, `yscale` et
`title` du `noeud_*.py` correspondant. Par exemple pour
`inkscape/noeud-plat.svg` : `depth` = `1 -1 1 1 -1 1 -1 1 -1 -1 1 -1`,
yscale = `0.8`.

Le **Sens des torons** se déduit de la liste `paths` du `noeud_*.py` : le
chemin à la position *i* de la liste (en comptant les chaînes vides `''`, à
partir de 0) prend `+` si *i* est pair et `-` si *i* est impair. Exemples :

| `paths` dans `noeud_*.py` | Sens des torons |
|---|---|
| `['A']` | `+` |
| `['A', '', 'B']` (nœud plat) | `+ +` |
| `['A', 'B']` (nœud de pêcheur) | `+ -` |

## Fichiers
| Fichier | Rôle |
|---|---|
| `knotsvg.py` | géométrie commune (Bézier, torons, couches) et sortie SVG via svgwrite |
| `noeud_*.py` | description de chaque nœud |
| `knotsvg.tex` | mise en page du livret |
| `inkscape/knotsvg_inkscape.py`, `inkscape/knotsvg.inx` | extension Inkscape, qui importe `knotsvg.py` |
| `inkscape/gensvg.py` | génère `inkscape/noeud-*.svg` (chemins et `sodipodi:nodetypes` des `noeud_*.py`) |
| `inkscape/noeud-*.svg` | chemins des nœuds, pour tester l'extension (générés par `make svg`, non versionnés) |
