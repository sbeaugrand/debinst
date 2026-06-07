# ---------------------------------------------------------------------------- #
## \file install-op-gcode-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/gcode-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh https://linuxcnc.org/docs/html/gcode.html
    sed -i 's@"http://linuxcnc.org/docs/devel/html/" + @@' gcode.html
    popd
    logTodo "chromium file://$dir/gcode.html"
fi
