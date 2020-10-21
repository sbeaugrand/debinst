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
./0install.sh hardware/install-op-pc-...
```

# Création d'une nouvelle debian sur clé USB

```
make pkgs
make iso
pv ~/data/install-build/simplecdd-1amd64/images/debian-10-amd64-DVD-1.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
La liste des paquets debian sont dans: simplecdd-op-1amd64/list.txt

La liste des paquets créés sont dans: buildpackage-op-1/build/list.txt

# Création d'une machine virtuelle dans windows
```
./1buildpackage.sh buildpackage-op-2min dist
./2simplecdd.sh simplecdd-op-2min buildpackage-op-2min
cd 3packer && make tar
```
Continuer avec 3packer/README.md (cmark-gfm 3packer/README.md | lynx -stdin)

# Création d'une debian live
Mettre à jour le mirroir local
```
./2simplecdd.sh simplecdd-op-1amd64 buildpackage-op-1
cd 5livebuild
make mirror
make http
```
Configurer et créer
```
cd 5livebuild
make config
make sync
make clean
make installer
make aptsources
make binary
pv build/live-image-amd64.hybrid.iso | sudo dd bs=4M oflag=dsync of=/dev/sdb
```
Persistance (optionnel) et quatrième partition (optionnel)
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
/sbin/mkfs.ext2 /dev/sdb3
/sbin/mkfs.ext2 /dev/sdb4
/sbin/e2label /dev/sdb3 persistence
mount /mnt/b3
echo "/ union" >/mnt/b3/persistence.conf
umount /mnt/b3
```

# Installation sur Raspberry PI
```
unzip 2*-lite.zip
umount /media/$USER/*
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

# Installation sur Rock PI S
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
Optionnel: [Réception infra rouge](install-op-rockpi/lirc/README.md) 

# Exemple de création d'un paquet debinst restreint
```
cp -a buildpackage-op-2min buildpackage-op-spam
cp -a simplecdd-op-2min simplecdd-op-spam
mkdir install-pr-spam
ln -s ~/install/debinst/install-pr-spam ~/install/spam
cd install-pr-spam
ln -s ../buildpackage-pr-spam/list.txt
cp ../0install.sh .  # or link
cp ../install-*-res.sh .  # or link
```

# Exemple de récupération d'un dépôt git
```
untar $name-$branch.tgz || gitClone git@exemple.org:dir/$name.git $branch || return 1
```
