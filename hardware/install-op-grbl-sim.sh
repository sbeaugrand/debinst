# ---------------------------------------------------------------------------- #
## \file install-op-grbl-sim.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
gitClone https://github.com/gnea/grbl.git || return 1
gitClone https://github.com/sbeaugrand/grbl-sim.git || return 1

dir=$bdir/grbl/grbl/grbl-sim
if notDir $dir; then
    cp -a $bdir/grbl-sim $dir
fi

if notFile $dir/gvalidate.exe; then
    pushd $dir || return 1
    make >>$log 2>&1 new
    popd
fi

file=$home/.local/bin/gvalidate
if notFile $file; then
    cp $dir/gvalidate.exe $file
fi

dir=$bdir/grbl
file=$dir/grbl.hex
if notFile $file; then
    pushd $dir || return 1
    make >>$log 2>&1
    popd
fi

logInfo "cd $dir"
logTodo "example for ARD-CNC-Kit1: avrdude -c arduino -p m328p -P /dev/ttyACM0 -U flash:w:grbl.hex"
