# ---------------------------------------------------------------------------- #
## \file install-op-emacs-php.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=/usr/share/emacs/site-lisp
file=php-mode.el
url=https://raw.githubusercontent.com/ejmr/php-mode/master

repo=$idir/../php-mode
[ -d $repo ] || sudo -u $user mkdir $repo

download $url/$file || return 1

isDir $dir || return 1

if notFile $dir/$file; then
    cp $repo/$file $dir/
fi

if grep -q "make-local-hook" $dir/$file; then
    sed -i 's/make-local-hook/make-local-variable/' $dir/$file
    emacs --eval='(byte-compile-file "'$dir/$file'")' --kill
fi

if notFile $dir/${file}c; then
    emacs --eval='(byte-compile-file "'$dir/$file'")' --kill
fi
