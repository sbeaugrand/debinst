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

# Installation sur debian radxa
```
gunzip -k rockpis_debian_buster_minimal_arm64_20200615_1225-gpt.img.gz
umount /media/$USER/*
pv rockpis*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur Rock PI S
```
ssh rock@192.168.x.xx  # password: rock
sudo apt-get update
sudo apt-get install rsync
exit
HOST=192.168.x.xx ./install-op-rockpi.sh
ssh rock@192.168.x.xx
cd install/debinst/install-op-rockpi
../0install.sh
```
Optionnel: [Réception infra rouge](lirc/README.md)

# Installation sur armbian
```
xz -k -d Armbian_20.11_Rockpi-s_buster_legacy_4.4.243_minimal.img.xz
umount /media/$USER/*
pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur Rock PI S
```
ssh root@192.168.x.xx  # password: 1234
exit
export user=xxx
HOST=192.168.x.xx ./install-op-rockpi.sh
ssh $user@192.168.x.xx
cd install/debinst/install-op-rockpi
../0install.sh
```
Optionnel: [Réception infra rouge](lirc/README.md)
