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
xz -k -d Armbian_20.11.6_Rockpi-s_buster_current_5.9.14_minimal.img.xz
xz -k -d Armbian_21.02.3_Orangepizero_buster_current_5.10.21.img.xz
xz -k -d Armbian_21.02.3_Nanopineo_buster_current_5.10.21.img.xz
umount /media/$USER/*
pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur la Pi
```
make ssh USER=root [HOST=pi]  # password: 1234
exit
make rsync [USER=$USER] [HOST=pi]
make ssh
cd install/debinst/armbian
make install
```
Attention (RockpiS) : en attendant que la branche stable 21.02 boote
([bug AR-593](https://armbian.atlassian.net/browse/AR-593)), il faut prendre la
version 20.11 et le [fix usb port](https://github.com/armbian/build/commit/fa2fd51) :
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
Optionnel:

# TSOP1838 Infrared receiver

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
[Lien pour le noyau 4.4](kernel_4.4.md)
