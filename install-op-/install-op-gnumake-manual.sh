# ---------------------------------------------------------------------------- #
## \file install-op-gnumake-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/gnumake-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh https://www.gnu.org/software/make/manual/make.html
    popd
    logTodo "chromium file://$dir/make.html"
fi
