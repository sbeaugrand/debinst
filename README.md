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
make iso  # or :
make iso ARCH=i386
pv ~/data/install-build/simplecdd-op-1amd64/images/debian-*-amd64-DVD-1.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
La liste des paquets debian sont dans: simplecdd-op-1amd64/list.txt

La liste des paquets créés sont dans: buildpackage-op-1/build/list.txt

# Création d'une debian nouvelle version sur clé USB
```
pv debian-live-11.0.0-amd64-lxde.iso | sudo dd bs=4M oflag=dsync of=/dev/sdc
```
Démarrer la live
```
sudo mkdir /mnt/a1
sudo mount /dev/sda1 /mnt/a1
ln -s /mnt/a1/home/*/data /home/user/data
cd /mnt/a1/home/*/install/debinst
rm simplecdd-op-1amd64/amd64/simple-cdd.conf
rm -fr ~/data/install-build/simplecdd-op-1amd64
sudo apt-get update
sudo apt-get install dh-make dosfstools mtools simple-cdd xorriso
sudo passwd
make iso
```

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

# [Installation sur ARM](armbian/README.md)

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
