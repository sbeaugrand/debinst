# ---------------------------------------------------------------------------- #
## \file install-op-openscad-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/openscad-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    wget -r -k -p -np -E -nv -nd https://openscad.org/cheatsheet/
    sed -i 's@https://en.wikibooks.org/w/index.php?title=@https://en.wikibooks.org/wiki/@' index.html
    sed 's/href=/\o001href=/g' index.html | tr '\001' '\n' | grep href= | cut -d'"' -f2 | grep wikibooks.org/wiki | cut -d'#' -f1 | sort -u | tee list
    cat list | xargs -I {} wget -r -k -p -E -nv -H -Dupload.wikimedia.org -e robots=off --reject-regex ".*Main_Page.*|.*:.*:.*" -R "index*","*Wikijunior*","*Wikibook*","*Print_version*" --wait 2 --random-wait {}
    sed -i 's@https://en.wikibooks.org/wiki/OpenSCAD_User_Manual@en.wikibooks.org/wiki/OpenSCAD_User_Manual@g' index.html
    sed -i -e 's/\([a-z]\+\)#/\1.html#/g' -e 's/.html.html/.html/' index.html
    popd
    logTodo "chromium $dir/index.html"
fi
