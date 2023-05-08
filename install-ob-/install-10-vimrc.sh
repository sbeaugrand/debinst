# ---------------------------------------------------------------------------- #
## \file install-10-vimrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
vimrc()
{
    if notFile $1; then
        touch $1
    fi
    notGrep tabstop     $1 && echo "set tabstop =4"     >>$1
    notGrep shiftwidth  $1 && echo "set shiftwidth =4"  >>$1
    notGrep softtabstop $1 && echo "set softtabstop =4" >>$1
    notGrep paste       $1 && echo "set paste"          >>$1
    notGrep ruler       $1 && echo "set ruler"          >>$1
    notGrep notitle     $1 && echo "set notitle"        >>$1
    notGrep syntax      $1 && echo "syntax on"          >>$1
    notGrep peachpuff   $1 && echo "colo peachpuff"     >>$1
    notGrep comment     $1 && echo "hi comment ctermfg=blue cterm=bold" >>$1
    notGrep expandtab   $1 && cat >>$1 <<EOF
let _curfile = expand("%:t")
if _curfile =~ "Makefile" || _curfile =~ "makefile" || _curfile =~ ".*\.mk"
    set noexpandtab
else
    set expandtab
endif
EOF
    notGrep xsel $1 && cat >>$1 <<EOF
if \$DISPLAY != '' && executable('xsel')
    xnoremap <C-C> :w !xsel -i -b<CR>
endif
EOF
    return 0
}
vimrc $home/.vimrc

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
