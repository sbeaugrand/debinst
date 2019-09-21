#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-op-parted-default.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    dev=$1
else
    dev=/dev/sda
fi

export LANG=en
sectors=`fdisk -l $dev | grep " $dev" | awk '{ print $(NF-1) }'`
echo "sectors = $sectors"
((size = sectors/1024/2048))
echo "size = $size"
echo "size - 32 = $((size - 32))"
echo -n "size partition 3 ? "
read part3
echo -n "size partition 4 ? "
read part4
echo ./install-op-parted.sh $dev 2 30 $part3 $part4
eval ./install-op-parted.sh $dev 2 30 $part3 $part4
