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

installScript()
{
    script=$1
    file=/usr/sbin/$script
    if notFile $file; then
        cp $idir/armbian/shutter/$script $file
    fi
}
installScript shutter-restart.sh

if [ ! -d /boot/grub ]; then
    file=$idir/projects/arm/sompi/remotes/shutter-pr-.txt
    if notLink $file; then
        ls -l $file
        cp -a $file $bdir/shutter.txt
        mv $file /run/shutter.txt
        chown root.root /run/shutter.txt
        ln -s /run/shutter.txt $file
    fi
fi

pushd shutter || return 1
make --no-print-directory install
/usr/sbin/shutter-restart.sh
popd
