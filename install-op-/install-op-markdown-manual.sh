# ---------------------------------------------------------------------------- #
## \file install-op-markdown-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/markdown-manual
wget="wget -r -k -p -np -E -q --show-progress"
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $wget www.markdownguide.org/cheat-sheet/index.html
    $wget www.markdownguide.org/basic-syntax/index.html
    $wget www.markdownguide.org/extended-syntax/index.html
    sed -i "s@https*://www.markdownguide.org/basic-syntax/@file://$dir/www.markdownguide.org/basic-syntax/index.html@g" www.markdownguide.org/cheat-sheet/index.html
    sed -i "s@https*://www.markdownguide.org/extended-syntax/@file://$dir/www.markdownguide.org/extended-syntax/index.html@g" www.markdownguide.org/cheat-sheet/index.html
    popd
    logTodo "chromium file://$dir/www.markdownguide.org/cheat-sheet/index.html"
fi
