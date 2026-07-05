# ---------------------------------------------------------------------------- #
## \file install-op-cmake-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/cmake-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh https://cmake.org/cmake/help/latest/
    popd
    logTodo "chromium file://$dir/cmake.org/cmake/help/latest/index.html"
fi
