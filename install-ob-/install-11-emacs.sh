# ---------------------------------------------------------------------------- #
## \file install-11-emacs.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# emacs24-lucid --font 6x13
# echo "emacs.fontBackend: x" >>~/.Xdefaults
# xrdb ~/.Xresources
# ---------------------------------------------------------------------------- #
ln -sf $idir/install-ob-/install-*-emacs.el $home/.emacs
