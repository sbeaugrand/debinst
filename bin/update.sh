#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file update.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
src=${1%%/}
dst=${2%%/}

diftmpfile=/tmp/dif.tmp
addtmpfile=/tmp/add.tmp
deltmpfile=/tmp/del.tmp
up1tmpfile=/tmp/up1.tmp
up2tmpfile=/tmp/up2.tmp

echo
LANGUAGE=fr diff -rq --exclude=*.[oa] "$src" "$dst" | \
tee $diftmpfile | sed 's/ et / /'
echo

# ---------------------------------------------------------------------------- #
# Seulement dans src
# ---------------------------------------------------------------------------- #
grep "Seulement dans $src[:/]" $diftmpfile |\
  cut -c16- | sed 's/: /\//' >$addtmpfile
len=`expr length $src`
size=`cat $addtmpfile | wc -l`
for ((i = 1; i <= size; i++)); do
    file=`head -n $i $addtmpfile | tail -n 1 | cut -c$((len + 2))-`
    if [ ${file:0-1:1} = '~' ]; then
        echo -n "supprimer $file dans $src/ ? (O/n) "
        read ret
        if [ "$ret" != n ]; then
            rm "$src/$file"
        fi
    else
        echo -n "ajouter $file dans $dst/ ? (O/n) "
        read ret
        if [ "$ret" != n ]; then
            cp -R "$src/$file" "$dst/$file"
        fi
    fi
done

# ---------------------------------------------------------------------------- #
# Seulement dans dst
# ---------------------------------------------------------------------------- #
grep "Seulement dans $dst[:/]" $diftmpfile |\
  cut -c16- | sed 's/: /\//' >$deltmpfile
size=`cat $deltmpfile | wc -l`
for ((i = 1; i <= size; i++)); do
    file=`head -n $i $deltmpfile | tail -n 1`
    echo -n "supprimer $file ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        rm -r "$file"
    fi
done

# ---------------------------------------------------------------------------- #
# Differences
# ---------------------------------------------------------------------------- #
grep "Les fichiers" $diftmpfile | cut -c14- |\
  gawk 'BEGIN { FS = " et "   } { print $1 }' >$up1tmpfile
grep "Les fichiers" $diftmpfile | cut -c14-  |\
  gawk 'BEGIN { FS = " et "   } { print $2 }' |\
  gawk 'BEGIN { FS = " sont " } { print $1 }' >$up2tmpfile
size=`cat $up1tmpfile | wc -l`
for ((i = 1; i <= size; i++)); do
    file1=`head -n $i $up1tmpfile | tail -n 1`
    file2=`head -n $i $up2tmpfile | tail -n 1`
    if [ -L "$file2" ]; then
        continue;
    fi
    if [ "$file2" -nt "$file1" ]; then
        echo "ATTENTION: fichier cible plus recent que $file1"
    fi
    echo -n "mettre a jour $file2 ? (O/n/d) "
    read ret
    if [ "$ret" = d ]; then
        diff "$file1" "$file2"
        echo -n "mettre a jour $file2 ? (O/n) "
        read ret
        if [ "$ret" != n ]; then
            cp "$file1" "$file2"
        fi
    elif [ "$ret" != n ]; then
        cp "$file1" "$file2"
    fi
done

rm -f $diftmpfile\
      $addtmpfile\
      $deltmpfile\
      $up1tmpfile\
      $up2tmpfile
