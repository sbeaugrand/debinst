# ---------------------------------------------------------------------------- #
## \file install-op-shutter.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=../latex/cal
file=build/sun
if notFile $dir/$file; then
    pushd $dir || return 1
    mkdir -p build
    make $file >>$log
    popd
fi

file=$idir/projects/arm/sompi/remotes/shutter-pr-.txt
if notLink $file; then
    ls -l $file
    cp -a $file $bdir/shutter.txt
    mv $file /run/shutter.txt
    ln -s /run/shutter.txt $file
fi

installScript()
{
    script=$1
    file=/usr/sbin/$script
    if notFile $file; then
        cp $idir/armbian/shutter/$script $file
    fi
}
installScript atd-start.sh
installScript shutter.sh

pushd shutter || return 1
make --no-print-directory install user=$user
make --no-print-directory stop
make --no-print-directory start
popd

if systemctl -q is-enabled atd; then
    systemctl disable atd
fi
