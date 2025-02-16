#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file bookmarks.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "-lite" ]; then
    sed 's/ICON="[^"]*"//' bookmarks.html >bookmarks-lite.html &&\
    tar czf bookmarks-lite.tgz bookmarks-lite.html
    exit $?
fi

if [ -n "$1" ]; then
    ti=$1
else
    echo "Usage: `basename $0` [-lite] [<directory>]"
    exit 1
fi
if [ -f places.sqlite ]; then
    sqlite="sqlite3 places.sqlite"
else
    sqlite="sqlite3 `ls ~/.mozilla/firefox/*/places.sqlite`"
fi

# ---------------------------------------------------------------------------- #
# dossier
# ---------------------------------------------------------------------------- #
dossier()
{
    local fk
    local i
    id=$1
    ti=`$sqlite "SELECT title FROM moz_bookmarks WHERE id=$id"`
    for ((j = 0; j < lv; ++j)); do
        echo -n " "
    done
    echo "<DT><H3>$ti</H3><DL>"
    lv=$(($lv+2))
    fk=`$sqlite "SELECT fk FROM moz_bookmarks WHERE parent=$1 AND type=1"`
    for i in $fk; do
        for ((j = 0; j < lv; ++j)); do
            echo -n " "
        done
        echo -n "<TD><A HREF=\""
        $sqlite "SELECT url FROM moz_places WHERE id=$i" | tr -d '\n'
        echo "\">"
        for ((j = 0; j < lv; ++j)); do
            echo -n " "
        done
        $sqlite "SELECT title FROM moz_bookmarks WHERE fk=$i" | tr -d '\n'
        echo "</A><BR/></TD>"
    done
    fk=`$sqlite "SELECT id FROM moz_bookmarks WHERE parent=$1 AND type=2"`
    for i in $fk; do
        dossier $i
    done
    lv=$(($lv-2))
    for ((j = 0; j < lv; ++j)); do
        echo -n " "
    done
    echo "</DL></DT><BR/>"
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
lv=0
id=`$sqlite "SELECT id FROM moz_bookmarks WHERE title=\"$ti\""`
if [ -z "$id" ]; then
    exit 1
fi
echo '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">'
echo "<DL>"
dossier $id
echo "</DL>"
