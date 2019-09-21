#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file tuxguitar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# vi ~/.asoundrc
# pcm.!default {
#     type hw
#     card 1
# }
# timidity -Os fichier.mid
# ---------------------------------------------------------------------------- #
timidity -iA -Os >/tmp/timidity.log 2>&1 &
tuxguitar >/tmp/tuxguitar.log 2>&1
# Outils/Parametres/Son/Port
kill -15 `ps -C "timidity -iA -Os" -o pid=`
