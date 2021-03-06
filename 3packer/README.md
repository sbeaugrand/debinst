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

# Création d'une machine virtuelle dans windows
https://www.virtualbox.org/wiki/Downloads
```
choco install -y --version=6.0.14 virtualbox
```
https://www.packer.io/downloads.html
```
choco install -y packer
```
https://www.vagrantup.com/downloads.html
```
choco install -y vagrant
```
https://git-scm.com/download/win
```
choco install -y git
```
https://www.puttygen.com/download-putty#PuTTY_for_windows
```
choco install -y putty
```
(https://www.puttygen.com/download.php?val=4)
```
git-bash.exe
ls -l 3packer.sh 3packer
cp 3packer/Vagrantfile 3packer/vagrantup.sh 3packer/vagrantssh.sh .
source 3packer/shortcut.sh
ssh-keygen.exe -t rsa
cp $HOME/.ssh/id_rsa.pub 3packer/authorized_keys
```
PuTTYgen => Conversion => Import key id_rsa => Save private key id_rsa.ppk

Pageant => Add key id_rsa.ppk
```
git-bash.exe
source 3packer.sh /c/debian-10-amd64-DVD-1.iso
source vagrantup.sh
```
Copie des clés :
```
vagrant provision --provision-with id_rsa
```
Installation en ssh :
```
source vagrantssh.sh
passwd
sudo passwd
cd install/<path>
./0install.sh
```
Resolution :

Uncheck View => Auto-resize Guest Display

Login vagrant
```
cd install/<path>
./0install install-*-res.sh
```
