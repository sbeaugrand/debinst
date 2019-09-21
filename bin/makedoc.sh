#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file makedoc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
readOptions()
{
    texprog=2
    spell=n
    if (grep "a5paper" "$name.tex" 2> /dev/null); then
        book=
    else
        book=n
    fi

    for ac_option
    do
        case "$ac_option" in
            -b | -book | --book)
                book=o ;;
            -h | -help | --help)
                cat << EOF
Usage: ${0##*/} [options] <tex-file>
Options:
  -b, --book    faire un livret avec le prefixe livret_
  -h, --help    cette aide
  -i            mode interactif
  -n, --nobook  ne pas faire de livret
  -s, --spell   verifier l'orthographe
EOF
                exit 0 ;;
            -i)
                texprog=
                spell=
                book=
                ;;
            -n | -nobook | --nobook)
                book=n ;;
            -s | -spell | --spell)
                spell=o ;;
            *)
                filename="$ac_option" ;;
        esac
    done
}

readOptions $*  # Une premiere fois pour avoir le nom du fichier

if [ ! -f "$filename" ]; then
    echo "$filename: Aucun fichier"
    exit -1
fi
ext=${filename##*.}
if [ "$ext" != tex ]; then
    echo "$filename: Mauvaise extention"
    exit -1
fi
name=${filename%.tex}

readOptions $*  # Une seconde fois pour les options dependantes du fichier

modesfile=/usr/share/texmf/metafont/misc/modes.mf
if [ -f $modesfile ]; then
    echo
    echo "info: "`grep "localfont := " $modesfile`" in $modesfile"
    echo
fi

# ---------------------------------------------------------------------------- #
# orthographe
# ---------------------------------------------------------------------------- #
if [ -z "$spell" ]; then
    echo -n "orthographe ? (o/N) "
    read spell
    if [ -z "$spell" ]; then
        spell=n
    fi
fi
if [ "$spell" = o ]; then
    aspell -d francais -p "./$name.dic" -t -c "$name.tex"
fi

# ---------------------------------------------------------------------------- #
# compilation
# ---------------------------------------------------------------------------- #
if [ -z "$texprog" ]; then
    echo -ne "(1) postscript\n(2) pdf pdflatex\n(3) pdf dvipdf\n[1] "
    read texprog
    if [ -z "$texprog" ]; then
        texprog=1
    fi
fi
options="--halt-on-error"
if grep "write18" "$name.tex" >/dev/null 2>&1; then
    echo -n "--shell-escape ? (o/N) "
    read ret
    if [ "$ret" = o ]; then
        options="$options --shell-escape"
    fi
fi
case $texprog in
    1) latex    $options "$name.tex" ; dvips -o "$name.ps"  "$name.dvi" ;;
    2) pdflatex $options "$name.tex" ;;
    3) latex    $options "$name.tex" ; dvipdf   "$name.dvi" "$name.pdf" ;;
esac

# ---------------------------------------------------------------------------- #
# livret
# ---------------------------------------------------------------------------- #
if [ -z "$book" ]; then
    echo -n "livret ? (o/N) "
    read book
    if [ -z "$book" ]; then
        book=n
    fi
fi
if [ "$book" = o ]; then
    if [ $texprog = 1 ]; then
        psbook "$name.ps" | psnup -2 |\
          pstops "2:0,1U(21cm,29.7cm)" > "livret_$name.ps"
    else
        pdfbook -o "livret_$name.pdf" "$name.pdf"
    fi
fi

rm -f "$name.log" "$name.dvi"
