# ---------------------------------------------------------------------------- #
## \file install-op-tikz-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/tikz-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh https://tikz.dev/
    popd
    logTodo "chromium file://$dir/tikz.dev/index.html"
fi
