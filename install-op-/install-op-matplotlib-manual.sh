# ---------------------------------------------------------------------------- #
## \file install-op-matplotlib-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/matplotlib-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh -nd https://matplotlib.org/stable/gallery/index.html
    popd
    logTodo "chromium file://$dir/index.html"
fi
