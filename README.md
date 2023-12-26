# Installation sur une debian existante
```sh
cd
mkdir data
mkdir install
cd install
tar xzf debinst-dist.tgz
cd debinst
./0install.sh
./0install.sh hardware/install-op-pc-...
systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c './0install.sh install-op-/install-op-mplayer.sh'
```

# [Installation légère sur une debian existante avec ansible](cicd/hosts/localhost/README.md#Installation)

# Création d'une debian sur clé USB
```sh
make pkgs
make iso  # or make iso32
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1034771
mkdir ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/main/dep11
curl -o ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/main/dep11/Components-amd64.yml.gz https://debian.mirror.ate.info/dists/bookworm/main/dep11/Components-amd64.yml.gz
mkdir ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/non-free-firmware/dep11
curl -o ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/non-free-firmware/dep11/Components-amd64.yml.gz https://debian.mirror.ate.info/dists/bookworm/non-free-firmware/dep11/Components-amd64.yml.gz
make iso
pv ~/data/install-build/simplecdd-op-1arch64/images/debian-*-amd64-DVD-1.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
La liste des paquets debian sont dans: simplecdd-op-1arch64/list.txt

La liste des paquets créés sont dans: buildpackage-op-1/build/list.txt

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

# Création d'une debian nouvelle version sur clé USB (bookworm)
https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/
```sh
make pkgs
gnome-boxes debian-live-12.0.0-amd64-lxde.iso
sudo apt update
sudo apt install -y sshfs
sudo mkdir /mnt/a1
sudo chown user:user /mnt/a1
user=...
sshfs $user@10.0.2.2:/ /mnt/a1
grep -A15 debinst/README /mnt/a1/home/*/install/debinst/README.md
ln -s /mnt/a1/data /home/user/data
cd /mnt/a1/home/*/install/debinst
rm simplecdd-op-1arch64/amd64/simple-cdd.conf
rm -fr ~/data/install-build/simplecdd-op-1arch64
sudo apt-get install -y dh-make dosfstools mtools simple-cdd xorriso
make iso
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1034771
mkdir ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/main/dep11
curl -o ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/main/dep11/Components-amd64.yml.gz https://debian.mirror.ate.info/dists/bookworm/main/dep11/Components-amd64.yml.gz
mkdir ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/non-free-firmware/dep11
curl -o ~/data/install-build/simplecdd-op-1arch64/tmp/mirror/dists/bookworm/non-free-firmware/dep11/Components-amd64.yml.gz https://debian.mirror.ate.info/dists/bookworm/non-free-firmware/dep11/Components-amd64.yml.gz
make iso
cd
fusermount3 -u /mnt/a1
```

# [Création d'une machine virtuelle dans windows](3packer/README.md)

# Création d'une debian live
Mettre à jour le mirroir local :
```sh
make iso
cd 5livebuild
systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c 'make mirror'
make http
```
Configurer et créer :
```sh
cd 5livebuild
df .  # >21G or: mkdir /data/live && ln -s /data/live build
make config
make sync
make clean
make config
make installer
make aptsources
systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c 'make binary'
pv build/live-image-amd64.hybrid.iso | sudo dd bs=4M oflag=dsync of=/dev/sdb
```

<details>
  <summary>Persistance et quatrième partition</summary>

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
</details>

<details>
  <summary>Exemple pour une configuration avancée</summary>

  ```sh
  ln -s autostart-pc-b1 autostart-pr-symlink
  ln -s user-config-pc-b1.mk user-config-pr-symlink.mk
  ```
</details>

# [Installation sur ARM (armbian)](armbian/README.md)

# [Installation sur Raspberry Pi (raspbian)](raspbian/README.md)

# [Installation sur PinePhone (mobian)](mobian/README.md)

# Licence CeCILL 2.1

Copyright Sébastien Beaugrand

Ce logiciel est un programme informatique servant à créer, installer, et
configurer une debian de manière semi-automatique.

Ce logiciel est régi par la licence CeCILL soumise au droit français et
respectant les principes de diffusion des logiciels libres. Vous pouvez
utiliser, modifier et/ou redistribuer ce programme sous les conditions
de la licence CeCILL telle que diffusée par le CEA, le CNRS et l'INRIA
sur le site "http://www.cecill.info".

En contrepartie de l'accessibilité au code source et des droits de copie,
de modification et de redistribution accordés par cette licence, il n'est
offert aux utilisateurs qu'une garantie limitée.  Pour les mêmes raisons,
seule une responsabilité restreinte pèse sur l'auteur du programme,  le
titulaire des droits patrimoniaux et les concédants successifs.

A cet égard  l'attention de l'utilisateur est attirée sur les risques
associés au chargement,  à l'utilisation,  à la modification et/ou au
développement et à la reproduction du logiciel par l'utilisateur étant
donné sa spécificité de logiciel libre, qui peut le rendre complexe à
manipuler et qui le réserve donc à des développeurs et des professionnels
avertis possédant  des  connaissances  informatiques approfondies.  Les
utilisateurs sont donc invités à charger  et  tester  l'adéquation  du
logiciel à leurs besoins dans des conditions permettant d'assurer la
sécurité de leurs systèmes et ou de leurs données et, plus généralement,
à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.

Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
pris connaissance de la licence CeCILL, et que vous en avez accepté les
termes.
