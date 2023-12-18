# Persistance et quatrième partition
```
/sbin/fdisk /dev/sdb
n
p
3
16777216  # echo " 8 GB" | awk '{ print $1 * 1024 * 2048 }'
67108863  # echo "32 GB" | awk '{ print $1 * 1024 * 2048 }' | awk '{ print $0 - 1 }'
n
p
67108864  # echo "32 GB" | awk '{ print $1 * 1024 * 2048 }'
134217727 # echo "64 GB" | awk '{ print $1 * 1024 * 2048 }' | awk '{ print $0 - 1 }'
w
```
```sh
/sbin/mkfs.ext2 /dev/sdb3
/sbin/mkfs.ext2 /dev/sdb4
/sbin/e2label /dev/sdb3 persistence
mount /mnt/b3
echo "/ union" >/mnt/b3/persistence.conf
umount /mnt/b3
```

# Exemple pour une configuration avancée
```sh
ln -s autostart-pc-b1 autostart-pr-symlink
ln -s user-config-pc-b1.mk user-config-pr-symlink.mk
```
