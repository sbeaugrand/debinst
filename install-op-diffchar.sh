# ---------------------------------------------------------------------------- #
## \file install-op-diffchar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
vimdir=`ls -d /usr/share/vim/vim[0-9][0-9]`
if [ ! -d "$vimdir" ]; then
    return 1
fi

gitClone https://github.com/rickhowe/diffchar.vim || return 1

file=$vimdir/autoload/diffchar.vim
if notFile $file; then
    cp $bdir/diffchar/autoload/diffchar.vim $file
fi

file=$vimdir/plugin/diffchar.vim
if notFile $file; then
    cp $bdir/diffchar/plugin/diffchar.vim $file
fi
