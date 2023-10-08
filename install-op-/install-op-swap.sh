# ---------------------------------------------------------------------------- #
## \file install-op-swap.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note ./0install.sh -dev=sda1 install-op-/install-op-swap.sh
# ---------------------------------------------------------------------------- #
dev=`echo $args | cut -d '=' -f 2`
dev=/dev/${dev:-sda1}

cat <<EOF

sudo su
swapoff $dev
mkfs.ext4 $dev
cryptsetup -d /dev/urandom create cryptedswap $dev
mkswap /dev/mapper/cryptedswap
echo "cryptedswap $dev /dev/urandom swap" >>/etc/crypttab
echo "/dev/mapper/cryptedswap none swap sw 0 0" >>/etc/fstab
vi /etc/fstab  # suppr ancienne ligne
swapon -a

EOF
