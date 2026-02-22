#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file screen.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "reattach" ]; then
    screen -RR
elif [ "$1" = "quit" ]; then
    screen -list | grep Detached | awk '
{
  printf $1": ";
  if (system("screen -S "$1" -X quit")) {
    print "not killed";
  } else {
    print "killed";
  }
}'
else
    echo "Usage: screen.sh <reattach|quit>"
fi
