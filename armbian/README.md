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
Attention : en attendant que le commit https://github.com/armbian/build/commit/fa2fd517d12d09b04a751a34e614d75ab7a8699e
soit fusionné dans la branche https://github.com/armbian/build/commits/v20.11, il faut prendre la version de test (unstable).
Par exemple : Armbian_21.02.0-trunk.56_Rockpi-s_groovy_current_5.9.16_minimal.img.xz
```
xz -k -d Armbian_20.11.6_Rockpi-s_buster_current_5.9.14_minimal.img.xz
umount /media/$USER/*
pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur Rock PI S
```
make ssh USER=root [HOST=pi]  # password: 1234
exit
make rsync [USER=$USER] [HOST=pi]
make ssh
cd install/debinst/armbian
which make >/dev/null 2>&1 || sudo apt install make
make install
```
Optionnel:

# TSOP1838 Infrared receiver on RockpiS

```
```
```
 3v3                    GPIO2_A4        GND   --> RockpiS pins
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
```
[Lien pour le noyau 4.4](kernel_4.4.md)
