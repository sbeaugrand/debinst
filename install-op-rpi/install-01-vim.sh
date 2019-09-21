# ---------------------------------------------------------------------------- #
## \file install-01-vim.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/home/pi/.vimrc
if notFile $file; then
    echo "syntax on" >$file
    chown pi.pi $file
fi
