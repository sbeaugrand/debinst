# ---------------------------------------------------------------------------- #
## \file install-op-docopt-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/docopt-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh -nd http://docopt.org/
    popd
    logTodo "chromium file://$dir/index.html"
fi
