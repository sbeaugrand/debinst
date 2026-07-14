# Installation des fontes
```sh
cd ../..
./0install.sh install-ob-/install-13-fonts.sh
cd -
```

# Construction du fichier rune.svg
```sh
inkscape
```
Outil Rectangle

Objet => Fond et Contour => Fond ```Pas de remplissage``` Contour ```Aplat``` Style du contour => Épaisseur ```0.1mm```

Objet => Propriétés de l'objet ```L 20 H 30 Rx 4 Ry 4```

Édition => Ajuster la taille de la page à la selection

Affichage => Zoom => Dessin

Outil Texte

Texte => Texte et police => Police ```rune``` Taille de police ```56```

Outil sélection

Objet => Aligner et distribuer => Centrer

Outil Rectangle ```L 4 H 2 Rx 1 Ry 1``` + Centrer

Outil sélection Y ```2```

Copier Coller + Centrer + ```Y 26```

Enregistrer

# Construction du fichier rune.ngc
```sh
vi rune.svg +/O
inkscape rune.svg
```
Centrer

Edition => Tout sélectionner dans tous les calques

Chemin => Objet en chemin

Extensions => Gcodetools => Chemin vers G-code
```sh
make
```
