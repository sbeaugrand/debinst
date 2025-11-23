# Installation sur une debian existante
```sh
cd
mkdir data
mkdir install
cd install
git clone https://github.com/sbeaugrand/debinst.git
cd debinst
./0install.sh
```
<details>
  <summary>Installations optionnelles</summary>

  ```
  ./0install.sh hardware/install-op-pc-...
  ./0install.sh install-op-/install-op-...
  ```
</details>
<details>
  <summary>MPlayer</summary>

  ```
  systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c './0install.sh install-op-/install-op-mplayer.sh'
  ```
</details>
<details>
  <summary>Hotspot</summary>

  ```
  ./0install.sh hardware/install-op-hotspot.sh
  bin/hotspot
  ```
</details>
<details>
  <summary>Contrôle parental</summary>

  ```
  ./0install.sh install-op-/install-op-parental-control.sh
  ./0install.sh install-op-/install-op-parental-control2.sh
  ```
</details>

# [Installation légère sur une debian existante avec ansible](cicd/hosts/localhost/README.md#Installation)

# Création d'une debian sur clé USB
```sh
make pkgs
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1034771
sudo vi /usr/share/debian-cd/tools/generate_firmware_patterns +/'missing metadata file'  # comment 2 lignes
# trixie
sudo vi /usr/share/simple-cdd/build-simple-cdd +/'For amd64'  # comment 3 lines
sudo vi /usr/share/debian-cd/tools/boot/trixie/boot-x86 +/'amd64 i386'  # suppr i386
make iso
pv ~/data/install-build/simplecdd-op-1arch64/images/debian-*-amd64-DVD-1.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
La liste des paquets debian sont dans: simplecdd-op-1arch64/list.txt

La liste des paquets créés sont dans: buildpackage-op-1/build/list.txt

[~~No kernel modules were found~~](doc/no-kernel-modules-were-found.md)

# Création d'une debian légère sur clé USB
```sh
./1buildpackage.sh buildpackage-op-2ansible dist
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1034771
sudo vi /usr/share/debian-cd/tools/generate_firmware_patterns +/'missing metadata file'  # comment 2 lignes
# trixie
sudo vi /usr/share/simple-cdd/build-simple-cdd +/'For amd64'  # comment 3 lines
sudo vi /usr/share/debian-cd/tools/boot/trixie/boot-x86 +/'amd64 i386'  # suppr i386
./2simplecdd.sh simplecdd-op-2ansible buildpackage-op-2ansible
```

# Création d'une debian nouvelle version sur clé USB
https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/
```sh
gpg --keyserver hkps://keyring.debian.org:443 --recv-keys 0xDA87E80D6294BE9B
gpg --keyserver hkps://keyring.debian.org:443 --recv-keys 0x42468F4009EA8AC3
gpg --verify SHA512SUMS.sign SHA512SUMS
grep debian-live-13.1.0-amd64-lxde.iso$ SHA512SUMS >debian-live-13.1.0-amd64-lxde.sha
sha512sum -c debian-live-13.1.0-amd64-lxde.sha
sudo apt install openssh-server
make pkgs
gnome-boxes debian-live-13.1.0-amd64-lxde.iso
```
```sh
# lxterminal
sudo apt update
sudo apt install -y sshfs
sudo mkdir /mnt/a1
sudo chown user:user /mnt/a1
user=...
sshfs $user@10.0.2.2:/ /mnt/a1
grep -A15 debinst/README /mnt/a1/home/$user/install/debinst/README.md
ln -s /mnt/a1/data /home/user/data
cd /mnt/a1/home/$user/install/debinst
rm simplecdd-op-1arch64/amd64/simple-cdd.conf
rm -fr ~/data/install-build/simplecdd-op-1arch64
sudo apt-get install -y dh-make dosfstools mtools simple-cdd xorriso distro-info-data
sudo vi /usr/share/simple-cdd/tools/build/debian-cd +/rsync  # suppr -a
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1034771
sudo vi /usr/share/debian-cd/tools/generate_firmware_patterns +/'missing metadata file'  # comment 2 lines
# trixie
sudo vi /usr/share/simple-cdd/build-simple-cdd +/'For amd64'  # comment 3 lines
sudo vi /usr/share/debian-cd/tools/boot/trixie/boot-x86 +/'amd64 i386'  # suppr i386
make iso
cd
fusermount3 -u /mnt/a1
exit
```
```sh
sudo apt remove openssh-server
```

# Création d'une debian live
```sh
make live  # :
```
## Mettre a jour le mirroir local
```sh
make iso
cd 4livebuild
systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c 'make mirror'
make http
```
## Configurer et creer
```sh
cd 4livebuild
df .  # >28G or: mkdir /data/live && ln -s /data/live build
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
  ls -l /lib/modules  # 6.1.0-25-amd64
  vi Makefile +/config:
  # --linux-packages linux-image-6.1.0-25\
  # --linux-packages linux-headers-6.1.0-25\
  vi ../simplecdd-op-1arch64/list.txt +
  # linux-image-6.1.0-25-amd64
  # linux-headers-6.1.0-25-amd64
  ```
</details>

# [Installation sur ARM (armbian)](armbian/README.md)

# [Installation sur Raspberry Pi (raspbian)](raspbian/README.md)

# [Installation sur PinePhone (mobian)](mobian/README.md)

# [Création d'une machine virtuelle dans windows](3packer/README.md)

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
offert aux utilisateurs qu'une garantie limitée. Pour les mêmes raisons,
seule une responsabilité restreinte pèse sur l'auteur du programme, le
titulaire des droits patrimoniaux et les concédants successifs.

A cet égard l'attention de l'utilisateur est attirée sur les risques
associés au chargement, à l'utilisation, à la modification et/ou au
développement et à la reproduction du logiciel par l'utilisateur étant
donné sa spécificité de logiciel libre, qui peut le rendre complexe à
manipuler et qui le réserve donc à des développeurs et des professionnels
avertis possédant des connaissances informatiques approfondies. Les
utilisateurs sont donc invités à charger et tester l'adéquation du
logiciel à leurs besoins dans des conditions permettant d'assurer la
sécurité de leurs systèmes et ou de leurs données et, plus généralement,
à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.

Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
pris connaissance de la licence CeCILL, et que vous en avez accepté les
termes.
