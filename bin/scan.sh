#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file scan.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# udev :
#
# lsusb
# sudo vi /etc/udev/rules.d/56-sane-backends-autoconfig.rules
# ATTR{idVendor}=="055f", ATTR{idProduct}=="040b", MODE="0666"
# sudo udevadm control --reload-rules
# ---------------------------------------------------------------------------- #
# Exemple de fichier tex pour creer un pdf avec les valeurs par defaut :
#
# \documentclass[a4paper]{article}
# \usepackage{vmargin}
# \setmarginsrb{5mm}{5mm}{5mm}{5mm}{0mm}{0mm}{0mm}{0mm}
# \usepackage{graphics}
# \pagestyle{empty}
# \parindent0mm
# \pdfimageresolution150
#
# \begin{document}
# \includegraphics{01.png}\\
# \includegraphics{02.png}
# \end{document}
# ---------------------------------------------------------------------------- #
if [ "$1" = "-k" ]; then
    kill -15 `ps -C scanimage -o pid=`
    kill -15 `ps -C scanimage -o pid=`
    shift
    if [ -z "$1" ]; then
        exit 0
    fi
fi

if [ -z "$1" ]; then
    echo "Usage: `basename $0` [-k] <image-name>"
    exit 0
fi

image=$1

# ---------------------------------------------------------------------------- #
# dimensions
# ---------------------------------------------------------------------------- #
echo "1: 210 297"
echo "2: 297 210"
echo "3: 297 420"
echo -n "? [1] "
read ret
if [ -z "$ret" ]; then
    ret=1
fi
case "$ret" in
    1) lx=210; ly=297;;
    2) lx=297; ly=210;;
    3) lx=297; ly=420;;
    *) lx=`echo $ret | cut -d ' ' -f 1`; ly=`echo $ret | cut -d ' ' -f 2`;;
esac
if ((lx > ly)); then
    echo -n "rotation ? (0/n) "
    read ret
    if [ "$ret" != n ]; then
        aconv="-rotate 90"
    fi
fi
ascan="-x $lx -y $ly"

# ---------------------------------------------------------------------------- #
# marges
# ---------------------------------------------------------------------------- #
echo -n "marges en mm ? [5] "
read ret
if [ -z "$ret" ]; then
    ret=5
fi
if ((ret > 0)); then
    ((lx = lx - ret * 2))
    ((ly = ly - ret * 2))
    ascan="-x $lx -y $ly -l $ret -t $ret"
fi

# ---------------------------------------------------------------------------- #
# resolution
# ---------------------------------------------------------------------------- #
echo -n "resolution ? [150] "
read ret
if [ -z "$ret" ]; then
    ret=150
fi
ascan="$ascan --resolution $ret"
aconv="$aconv -density $ret"

# ---------------------------------------------------------------------------- #
# couleurs
# ---------------------------------------------------------------------------- #
echo "1: Gray8"
echo "2: Color24"
echo -n "? [1] "
read ret
if [ -z "$ret" ]; then
    ret=1
fi
case "$ret" in
    1) ascan="$ascan --mode Gray8";;
    2) ascan="$ascan --mode Color24";;
    *) ascan="$ascan --mode $ret";;
esac

# ---------------------------------------------------------------------------- #
# format
# ---------------------------------------------------------------------------- #
echo "1: png"
echo "2: jpg"
echo -n "? [1] "
read ret
if [ -z "$ret" ]; then
    ret=1
fi
case "$ret" in
    1) ext=png;;
    2) ext=jpg;;
    *) ext=$ret;;
esac
if [ -f $image.$ext ]; then
    echo "attention: $image.$ext existe"
fi

# ---------------------------------------------------------------------------- #
# white-threshold
# ---------------------------------------------------------------------------- #
echo -n "white-threshold ? (o/N) "
read ret
if [ "$ret" = o ]; then
    echo -n "white-threshold ? [55000] "
    read ret
    if [ -z "$ret" ]; then
        ret=55000
    fi
    aconv="$aconv -white-threshold $ret"
fi

# ---------------------------------------------------------------------------- #
# quality
# ---------------------------------------------------------------------------- #
echo -n "quality ? [100] "
read ret
if [ -n "$ret" ]; then
    aconv="$aconv -quality $ret"
fi

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
echo "scanimage $ascan | convert - $aconv $image.$ext"
echo -n "? (O/n) "
read ret
if [ "$ret" != n ]; then
    scanimage $ascan | convert - $aconv $image.$ext
fi
