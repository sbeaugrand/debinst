#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file spurge.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
screen -list | grep Detached | awk '
{
  printf $1": ";
  if (system("screen -S "$1" -X quit")) {
    print "not killed";
  } else {
    print "killed";
  }
}'
