# ---------------------------------------------------------------------------- #
## \file install-op-fonts-cursive.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
name=frcursive
source $idir/install-op-/install-op-fonts-base.sh

# Stick fonts for cnc
dir=$texdir/fonts/source/public/frcursive
font=frcf6
file=$dir/$font.mf
if notGrep "\.0 pt" $file; then
    sed -i 's/240 pt/0 pt/' $file
    tracepfb $font
fi
font=frcf10
file=$dir/$font.mf
if notGrep "\.0 pt" $file; then
    sed -i 's/400 pt/0 pt/' $file
    tracepfb $font
fi
font=frcf14
file=$dir/$font.mf
if notGrep "\.0 pt" $file; then
    sed -i 's/576 pt/0 pt/' $file
    tracepfb $font
fi
