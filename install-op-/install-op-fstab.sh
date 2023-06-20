# ---------------------------------------------------------------------------- #
## \file install-op-fstab.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/fstab

list=""
for f in b1 b2 b3 b4 c1 c2 c3 c4 m1 m2 m3 m4; do
    dir=/mnt/$f
    if notDir $dir; then
        list="$list $dir"
    fi
    if notGrep $dir $file; then
        if [ "${f:0:1}" = m ]; then
            i=${f:1:1}
            sudoRoot sed -i "'\$a/dev/mmcblk0p$i $dir auto users,noauto 0 0'" $file
        else
            sudoRoot sed -i "'\$a/dev/sd$f $dir auto users,noauto 0 0'" $file
        fi
    fi
done
if [ -n "$list" ]; then
    sudoRoot mkdir $list
fi
