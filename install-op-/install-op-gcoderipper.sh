# ---------------------------------------------------------------------------- #
## \file install-op-gcoderipper.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example :
##       g-code_ripper.py -g laser-grbl-sundial.ngc  # Export w/o Rapid Moves
#        inkscape laser-grbl-sundial.dxf
# ---------------------------------------------------------------------------- #
version=0.26
repo=$idir/../repo
file=G-Code_Ripper-${version}_src.zip
download https://www.scorchworks.com/Gcoderipper/$file || return 1
untar $file || return 1

file=$home/.local/bin/g-code_ripper.py
cat $bdir/G-Code_Ripper-${version}_src/g-code_ripper.py |\
 tr -d '\r' | sed 's@/python@/env python3@' >$file
chmod 755 $file
