#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-op-parted.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# root:~> ./install-op-parted.sh /dev/sdb 12 32 8 5
# sudo parted /dev/sdb rm 1
# sudo parted /dev/sdb mkpart ext2 2048 25165823
# sudo parted /dev/sdb mkpart ext2 25165824 92274687
# sudo parted /dev/sdb mkpart ext2 92274688 109051903
# sudo parted /dev/sdb mkpart ext2 109051904 120963071
# max = 120963071
# ---------------------------------------------------------------------------- #
if [ -z "$1" ] || [ ! -b "$1" ]; then
    echo "Usage: `basename $0` <dev> [size]..."
    exit 1
fi
dev=$1
shift

echo
sectors=`LANG=en fdisk -l $dev | grep " $dev" | awk '{ print $(NF-1) }'`
echo "sectors = $sectors"
((size = sectors / 1024 / 2048))
echo "size = $size"
echo

n=`parted $dev print | grep -c "^ [1-9]"`
m=`parted $dev unit s print |\
 grep "Disk /" | cut -d ':' -f 2 | sed 's/[^0-9]//g'`
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

echo
echo "max = $m"
echo

exit 0
