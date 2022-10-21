# Licence

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

# Installation sur armbian
## [Orange Pi Zero](https://www.armbian.com/orange-pi-zero/)
![Orange Pi Zero](https://www.armbian.com/wp-content/uploads/2018/02/orangepizero-300x169.png)
```
sha256sum -c Armbian_22.08.2_Orangepizero_bullseye_current_5.15.69.img.xz.sha
xz -k -d Armbian_22.08.2_Orangepizero_bullseye_current_5.15.69.img.xz
```

## [Nanopi Neo](https://www.armbian.com/nanopi-neo/)
![Nanopi Neo](https://www.armbian.com/wp-content/uploads/2018/02/nanopineo-300x169.png)
```
sha256sum -c Armbian_22.08.1_Nanopineo_bullseye_current_5.15.63.img.xz.sha
xz -k -d Armbian_22.08.1_Nanopineo_bullseye_current_5.15.63.img.xz
```

## [Rockpi S](https://www.armbian.com/rockpi-s/)
![Rockpi S](https://www.armbian.com/wp-content/uploads/2019/11/rockpi-s-300x169.png)
```
sha256sum -c Armbian_21.05.4_Rockpi-s_buster_edge_5.12.10_minimal.img.xz.sha
xz -k -d Armbian_21.05.4_Rockpi-s_buster_edge_5.12.10_minimal.img.xz

# For bullseye, rtc is broken :
df .  # 6,7G needed
git clone -b v22.08 https://github.com/armbian/build.git armbian-build
cd armbian-build
sed -i 's/^IDBLOADER_BLOB/#IDBLOADER_BLOB/' config/sources/families/rockpis.conf
touch .ignore_changes
sudo apt install debootstrap
sudo modprobe loop
systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c './compile.sh BOARD=rockpi-s BRANCH=edge BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no CLEAN_LEVEL=, RELEASE=bullseye SKIP_EXTERNAL_TOOLCHAINS=yes'
cd output/images
ls -l Armbian_22.08.2_Rockpi-s_bullseye_edge_5.19.16_minimal.img
```

## Installation
```
umount /media/$USER/*
pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur la Pi
```
./find-ip.sh
keychain ~/.ssh/id_rsa
make ssh user=root [host=pi]  # password: 1234
exit
make rsync [user=$USER] [host=pi] [shutter=y]
make ssh
cd install/debinst/armbian
which make >/dev/null || sudo apt install make
make install
sudo reboot
make ssh
cd install/debinst/armbian
rw
make volume
```
Optionnel:

# Infrared receiver - TSOP1838
```
```
```
 3v3                     Pin 7          GND   --> Pi pins
  |                        |             |
  |                        \             |
  |                        / 1k          |
  |                        \             |
  |          47k           |             |
  |---------/\/\/\---------+             |
  |                        |             |
  O                        O             O    --> 1838 pins
  |          100k          |     NPN     |
  |---------/\/\/\---------+-----\_/-----|
  |                               |      |
```
```
make lirc
sudo reboot
# Tests:
mode2 -d /dev/lirc0 -H default
sudo ir-keytable -p nec -t
```
# Real Time Clock - DS1302
```
make rtc
```
# Oled i2c display - SH1106
```
make oled
make oscreensaver
```
# MP3 server
```
make mp3server
```
# Shutter
```
make shutter
```
# USB to TTL - CH340G
```
```
```
                 Pi pins
Module           5V  2
 5V _            5V  4
VCC _            GND 6
3V3 _|     _____ TX  8
 TX _____ /_____ RX  10
 RX _____/           12
GND ____________ GND 14
```
Command for RockpiS : `sudo screen /dev/ttyUSB0 1500000`
# Device Tree recompilation
```
git clone https://github.com/armbian/build.git armbian-build
cd armbian-build
./compile.sh  BOARD=rockpi-s BRANCH=current KERNEL_ONLY=yes KERNEL_CONFIGURE=no
export user=xxx
export host=xxx
scp output/debs/linux-image-current-rockchip64_21.02.0-trunk_arm64.deb $user@$host:/home/$user/
scp output/debs/linux-dtb-current-rockchip64_21.02.0-trunk_arm64.deb $user@$host:/home/$user/
ssh $user@$host
sudo dpkg -i linux-image-current-rockchip64_21.02.0-trunk_arm64.deb
sudo dpkg -i linux-dtb-current-rockchip64_21.02.0-trunk_arm64.deb
sudo reboot
```
[Lien pour le noyau 4.4](kernel_4.4.md)
