# Supprimer une image d'un pdf
```sh
mutool clean -d -i src.pdf tmp.pdf
vi tmp.pdf +/Image  # stream\nendstream
vi tmp.pdf +/Im1  # cleanup all
mutool clean tmp.pdf dst.pdf
```
