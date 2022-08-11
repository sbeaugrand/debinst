# ---------------------------------------------------------------------------- #
## \file install-op-uncrustify.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notLink $home/.uncrustify.cfg; then
    ln -s $idir/install-op-/install-op-uncrustify.cfg $home/.uncrustify.cfg
fi
