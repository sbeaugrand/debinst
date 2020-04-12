# ---------------------------------------------------------------------------- #
## \file install-op-ariettaG25.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
url=https://www.acmesystems.it/download/microsd/Arietta-03aug2017
dev=/dev/mmcblk0

download $url/boot.tar.bz2 || return 1
download $url/rootfs.tar.bz2 || return 1

if [ ! -b $dev ]; then
    echo " error: $dev not found"
    return 1
fi

export PATH=$PATH:/sbin
max=`parted $dev unit s print | grep "Disk /" | cut -d ':' -f 2 | sed 's/[^0-9]//g'`
((max--))
cat << EOF

su
export PATH=\$PATH:/sbin
parted $dev unit s print
parted /dev/mmcblk0 rm ...
parted /dev/mmcblk0 unit s mkpart primary fat32 2048 $((128 * 2048 - 1))  # 128 MiB (sector size = 512B)
parted /dev/mmcblk0 unit s mkpart primary ext4 $((128 * 2048)) $max
partprobe -s $dev

mkfs.vfat /dev/mmcblk0p1
mkfs.ext4 /dev/mmcblk0p2
mount /mnt/m1
mount /mnt/m2
tar --no-same-owner -xjpSf $repo/boot.tar.bz2 -C /mnt/m1
tar -xjpSf $repo/rootfs.tar.bz2 -C /mnt/m2
sync
umount /mnt/m1
umount /mnt/m2

install-op-ariettaG25/ssh-arietta.sh
ssh root@192.168.10.10 date \`date +%m%d%H%M%Y -d '+1 min'\`
cd projects/vlfSpectrum && make tar && cd -
rsync -ai ~/install/debinst/projects/vlfSpectrum.tgz root@192.168.10.10:/root/

ssh root@192.168.10.10
echo "nameserver 212.27.40.240" >/etc/resolv.conf
echo "nameserver 212.27.40.241" >>/etc/resolv.conf
apt install make
tar xzf vlfSpectrum.tgz
cd vlfSpectrum
make
make adc ADC=g25
build/adc

EOF
