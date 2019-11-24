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

# Installation sur une debian existante
```
cd
mkdir data
mkdir install
cd install
tar xzf debinst-dist.tgz
cd debinst
./0install.sh
./0install.sh install-op-pc-...
```

# Création d'une nouvelle debian sur clé USB

```
./1buildpackage.sh buildpackage-op-1
./2simplecdd.sh simplecdd-op-1amd64 buildpackage-op-1
pv ~/data/install-build/simplecdd-1amd64/images/debian-10-amd64-DVD-1.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
La liste des paquets debian sont dans: simplecdd-op-1amd64/list.txt

La liste des paquets créés sont dans: buildpackage-op-1/build/list.txt

# Création d'une machine virtuelle dans windows
https://www.virtualbox.org/wiki/Downloads

https://www.packer.io/downloads.html

https://git-scm.com/download/win

https://www.puttygen.com/download-putty#PuTTY_for_windows

(https://www.puttygen.com/download.php?val=4)
```
git-bash.exe
ls -l packer_*.zip 3packer.sh 3packer
cp 3packer/Vagrantfile 3packer/vagrantup.sh 3packer/vagrantssh.sh .
source 3packer/shortcut.sh
unzip packer_1.4.4_windows_amd64.zip
ssh-keygen.exe -t rsa
cp $HOME/.ssh/id_rsa.pub 3packer/authorized_keys
```
PuTTYgen => Conversion => Import key id_rsa => Save private key id_rsa.ppk

Pageant => Add key id_rsa.ppk
```
./1buildpackage.sh buildpackage-op-2min
./2simplecdd.sh simplecdd-op-2min buildpackage-op-2min
git-bash.exe
source 3packer.sh /c/debian-10-amd64-DVD-1.iso
source vagrantup.sh
source vagrantssh.sh
passwd
sudo passwd
cd install/debinst
./0install.sh
```

# Installation sur Raspberry PI
```
unzip 2*-lite.zip
# umount /media/$USER/*
pv 2*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
sync
```
Enlever et remettre la carte SD
```
touch /media/$USER/boot/ssh
umount /media/$USER/*
```
Démarrer sur Raspberry PI
```
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.x.xx
keychain ~/.ssh/id_rsa
RPI=192.168.x.xx ./install-op-rpi.sh  # password: raspberry
ssh pi@192.168.x.xx
cd install/debinst/install-op-rpi
../0install.sh
sudo reboot
ssh pi@192.168.x.xx
cd install/debinst/install-op-rpi
rw
../0install.sh install-op-audio.sh
../0install.sh install-op-llctl.sh install-op-volet.sh
ro
```
