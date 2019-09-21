# ---------------------------------------------------------------------------- #
## \file install-op-diffchar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
vimdir=/usr/share/vim/vim80
gitClone https://github.com/rickhowe/diffchar.vim || return 1

pushd $bdir/diffchar.vim || return 1
cp autoload/diffchar.vim $vimdir/autoload/
cp plugin/diffchar.vim $vimdir/plugin/
popd
