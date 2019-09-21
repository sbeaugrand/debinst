#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file parted.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# parted.sh 4 40 8 8
# sudo parted /dev/sdb rm 1
# sudo parted /dev/sdb unit s mkpart primary ext2 2048 8388607
# sudo parted /dev/sdb unit s mkpart primary ext2 8388608 92274687
# sudo parted /dev/sdb unit s mkpart primary ext2 92274688 109051903
# sudo parted /dev/sdb unit s mkpart primary ext2 109051904 125927423
# max = 125927423
# ---------------------------------------------------------------------------- #
dev=/dev/sdb
n=`sudo parted $dev print | grep -c "^ [1-9]"`
m=`sudo parted /dev/sdb unit s print | grep "Disk /" | sed 's/[^0-9]//g'`
((m--))
for ((i = n; i > 0; i--)); do
    echo "sudo parted $dev rm $i"
done
i=2048
k=0
for a in $*; do
    j=`echo $k $a | awk '{ print ($1 + $2) * 1024 * 2048 - 1 }'`
    if ((j > m)); then
        echo "sudo parted $dev unit s mkpart primary ext2 $i $j"
        echo "error: max = $m"
        exit 1
    fi
    if ((j + 1024 * 2048 > m)); then
        j=$m
    fi
    echo "sudo parted $dev unit s mkpart primary ext2 $i $j"
    ((i = j + 1))
    ((k = k + a))
done
echo "max = $m"
if ((j < m)); then
    echo "reste = $((m - j))"
fi
exit 0
