# runecarver

Usinage de runes en relief au fond d'une poche, avec une fraise cylindrique et
la librairie opencamlib.

Chaque rune est décrite par un fichier `.scad`. `make` produit pour chacune :

- `build/<rune>.stl` (OpenSCAD) ;
- `build/<rune>.ngc` (G-code, par `runecarver.py`) ;
- `build/<rune>.png` (aperçu des trajectoires).

```sh
sudo apt install openscad python3-opencamlib python3-shapely python3-matplotlib
make
```

Le programme peut aussi être lancé seul :

```sh
python3 runecarver.py build/runeDagaz.stl [-o build/runeDagaz.ngc] [options]
python3 runecarver.py -h
```

La règle `build/%.ngc` du Makefile masque la sortie standard, qui ne contient
que les messages `~AdaptiveWaterline_py()` de la bibliothèque. Le programme
écrit ses propres messages sur la sortie d'erreur.

## Principe

- **Hauteurs** : elles sont déduites des faces horizontales du STL tournées vers
  le haut. La plus haute est le dessus de la pièce, la plus basse le fond de la
  poche, et celles entre les deux sont le haut des îlots (rune, oblong...).
- **Deux passages** :
  - le premier à mi-hauteur de la poche, remonté si besoin juste au-dessus des
    îlots (0,04 mm de garde) pour ne rencontrer que les bords extérieurs ;
  - le second au fond de la poche, autour des îlots.
  `--z1` et `--z2` permettent d'imposer ces hauteurs.
- **Contours** : ils sont calculés par opencamlib. Pour obtenir le contour
  situé à une distance R des parois, on prend le tracé du centre d'une fraise
  virtuelle de rayon R (`AdaptiveWaterline` avec `CylCutter(2R)`). R varie du
  rayon de la fraise vers l'intérieur, par pas de 0,8 mm (`--step`).
- **Ordre** : les contours sont rangés en arbre et usinés du plus intérieur
  vers les bords. Quand plusieurs zones sont séparées, chacune a son propre
  point de départ.
- **Usinage en avalant**, avec la broche en M3 : les contours de la poche sont
  parcourus dans le sens trigo et ceux des îlots dans le sens horaire.
- **Entrée dans la matière** : la fraise descend en rampe le long du contour,
  avec une pente de 0,15 au maximum (`--ramp`). Sur un petit contour, la rampe
  devient une hélice. Elle plonge droit uniquement si le point est déjà usiné.
- **Liaisons** : entre deux contours, l'outil reste à la profondeur de coupe
  seulement si le trajet reste dans la zone autorisée et traverse peu de
  matière non usinée. Sinon il remonte à la hauteur de dégagement (`--zsafe`).
- **Contrôle** : pour chaque passage, le programme affiche la surface que la
  fraise peut atteindre et la part qui n'a pas été usinée.

L'origine est celle du STL : centre de la pièce, avec Z=0 sur le dessus. Les
avances, la vitesse de broche, le diamètre de la fraise et le pas sont des
options (`-h`).

Le nombre de lignes du G-code varie légèrement d'une exécution à l'autre, car
les waterlines adaptatives sont calculées en parallèle. Le programme n'a pas
encore été testé sur une machine.

## Contraintes sur les runes

- Les parois de la poche et des îlots doivent être verticales : le contour du
  fond est calculé un peu au-dessus du fond (0,1 mm au plus).
- Les angles rentrants doivent être dégagés pour la fraise : variable `T` des
  `.scad`, diamètre de la fraise plus une marge de 0,2 mm.

## Runes

### runeDagaz

![runeDagaz](build/runeDagaz.png)

- Passage 1 à -1,45 et non -1,5 : avec `m=0.01`, le haut de la rune est à
  -1,49, donc couper à -1,5 l'entamerait légèrement.
- La rune ne touche pas le fond de la poche : elle commence à -2,99 alors que
  le fond est à -3. Les contours du passage 2 sont donc calculés à -2,9 et
  l'usinage se fait à -3. Ce `+m` pourrait être corrigé dans le `.scad`.
- La fraise de 2 mm passe dans les fentes de 2,2 mm entre le X et les barres,
  ainsi que dans les dégagements circulaires du centre. Si la fraise a du
  faux-rond, on peut passer la marge à 0,3 mm.
- Environ 3300 à 3400 lignes, soit environ 4,5 min de coupe à F300.
