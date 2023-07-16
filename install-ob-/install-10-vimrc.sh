# ---------------------------------------------------------------------------- #
## \file install-10-vimrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
vimdir=`ls -d /usr/share/vim/vim[0-9][0-9]`
if [ ! -d "$vimdir" ]; then
    return 1
fi

file=$vimdir/filetype.vim
isFile $file || return 1

if notGrep Vagrantfile $file; then
    cp $file $tmpf
    cat >>$tmpf <<EOF

" Vagrantfile
au BufNewFile,BufRead Vagrantfile setfiletype ruby
EOF
    sudoRoot cp $tmpf $file
fi
