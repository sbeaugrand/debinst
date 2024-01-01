# Création d'une debian nouvelle version sur clé USB (bullseye)
```sh
make pkgs
pv debian-live-11.0.0-amd64-lxde.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
Démarrer la live
```sh
sudo mkdir /mnt/a1
sudo mount /dev/sda1 /mnt/a1
ln -s /mnt/a1/home/*/data /home/user/data
cd /mnt/a1/home/*/install/debinst
rm simplecdd-op-1arch64/amd64/simple-cdd.conf
rm -fr ~/data/install-build/simplecdd-op-1arch64
sudo apt-get update
sudo apt-get install dh-make dosfstools mtools simple-cdd xorriso
sudo passwd
make iso
```
