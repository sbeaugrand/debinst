# ---------------------------------------------------------------------------- #
## \file install-op-yaml-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/yaml-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh https://yaml-multiline.info/
    popd
    logTodo "chromium file://$dir/index.html"
fi
