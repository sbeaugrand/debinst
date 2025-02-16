#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file volet.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "haut" ]; then
    gpio=18
elif [ "$1" = "bas" ]; then
    gpio=23
else
    echo "Usage: `basename $0` (haut | bas)"
    exit 1
fi
echo $gpio >/sys/class/gpio/export && \
echo out >/sys/class/gpio/gpio$gpio/direction && \
echo 1 >/sys/class/gpio/gpio$gpio/value && \
sleep 1 && \
echo 0 >/sys/class/gpio/gpio$gpio/value && \
echo $gpio >/sys/class/gpio/unexport
