# ---------------------------------------------------------------------------- #
## \file install-op-fonts-cursive.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=frcursive
source $idir/install-op-/install-op-fonts-base.sh

# Stick font for cnc
dir=$texdir/fonts/source/public/frcursive
file=$dir/frcf10.mf
if notGrep "\.0 pt" $file; then
    pushd $dir || return 1
    sed -i 's/400 pt/0 pt/' $file
    tfm=$texdir/fonts/tfm/public/$name/frcf10.tfm
    enc=$idir/install-ob-/install-13-fonts/T1-WGL4.enc
    mftrace --formats=pfb -V --tfmfile=$tfm -e $enc frcf10.mf >>$log 2>&1
    mv frcf10.pfb $texdir/fonts/type1/public/frcursive/
    popd
fi
