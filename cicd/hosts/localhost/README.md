# Installation
```
make sudoers
make local
make extraroles
```

# Crypted partition

## Usage example
```
sudo dd if=/dev/random of=/root/luksKey bs=512 count=8
sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
ansible-playbook ../../makefiles/includeroles.yml \
  -e host=all -e list="['crypted']" -e dev=sda3 -e mnt=data
sudo systemctl enable data.mount
```

## Disable
```
sudo cryptsetup luksRemoveKey /dev/sda3 /root/luksKey
```

## Re-enable
```
sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
```

## Remove
```
sudo cryptsetup luksRemoveKey /dev/sda3 /root/luksKey
sudo systemctl disable data.mount
```
