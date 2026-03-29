# ---------------------------------------------------------------------------- #
## \file install-op-openscad-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Total wall clock time: 21m
##       Downloaded: 608 files, 26M
# ---------------------------------------------------------------------------- #
dir=$bdir/openscad-manual
LANG=C
wget="wget -e robots=off -nv -E --convert-links --mirror --page-requisites"

if notDir $dir; then
    mkdir $dir
    pushd $dir

    $wget\
 --no-directories\
 --no-parent\
 https://openscad.org/cheatsheet/

    sed -i\
 -e 's@w/index.php?title=@wiki/@'\
 -e 's@https://en.wikibooks.org@en.wikibooks.org@g'\
 -e 's/\([a-z]\+\)#/\1.html#/g'\
 -e 's/.html.html/.html/'\
 -e 's/Text"/Text.html"/'\
 -e 's/Include_Statement"/Include_Statement.html"/'\
 index.html

    $wget\
 --wait 2\
 --random-wait\
 --reject "index*","auth*","Print_version"\
 --accept-regex ".*OpenSCAD_User_Manual.*|.*commons.*"\
 --reject-regex ".*:.*:.*"\
 --domains en.wikibooks.org,upload.wikimedia.org\
 --span-hosts\
 https://en.wikibooks.org/wiki/OpenSCAD_User_Manual\
 2>&1 | sed -e 's/.* URL://' -e 's/ -> .*//'

    popd
    logTodo "chromium $dir/index.html"
fi
