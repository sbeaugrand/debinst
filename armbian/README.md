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
```
sha256sum -c Armbian_22.05.1_Orangepizero_bullseye_current_5.15.43.img.xz.sha
xz -k -d Armbian_22.05.1_Orangepizero_bullseye_current_5.15.43.img.xz

sha256sum -c Armbian_22.05.1_Nanopineo_bullseye_current_5.15.43.img.xz.sha
xz -k -d Armbian_22.05.1_Nanopineo_bullseye_current_5.15.43.img.xz

xz -k -d Armbian_21.05.4_Rockpi-s_buster_edge_5.12.10_minimal.img.xz

umount /media/$USER/*
pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur la Pi
```
ping 192.168.0.xx
vi /etc/hosts  # 192.168.0.xx pi
ssh-keygen -f ~/.ssh/known_hosts -R pi
keychain ~/.ssh/id_rsa
make ssh user=root [host=pi]  # password: 1234
exit
make rsync [user=$USER] [host=pi]
make ssh
cd install/debinst/armbian
which make >/dev/null || sudo apt install make
make install
sudo reboot
make ssh
amixer -q set 'Line Out' 94% unmute
amixer -q set 'DAC' 98% unmute
rw
sudo alsactl store
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
```
# MP3 server
```
make mp3server
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
