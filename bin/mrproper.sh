#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mrproper.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=~/.bash_history.bak
if [ -f $file ]; then
    cp $file ~/.bash_history
    rm -f ~/.bash_history~
fi
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
