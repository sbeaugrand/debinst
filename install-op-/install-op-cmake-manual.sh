# ---------------------------------------------------------------------------- #
## \file install-op-cmake-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/cmake-manual
wget="wget -r -k -p -np -E -q --show-progress"
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $wget https://cmake.org/cmake/help/latest/
    popd
    logTodo "chromium file://$dir/cmake.org/cmake/help/latest/index.html"
fi
