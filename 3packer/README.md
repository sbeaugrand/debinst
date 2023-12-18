# Création d'une machine virtuelle dans windows
https://www.virtualbox.org/wiki/Downloads
```sh
choco install -y --version=6.0.14 virtualbox
```
https://www.packer.io/downloads.html
```sh
choco install -y packer
```
https://www.vagrantup.com/downloads.html
```sh
choco install -y vagrant
```
https://git-scm.com/download/win
```sh
choco install -y git
```
https://www.puttygen.com/download-putty#PuTTY_for_windows
```sh
choco install -y putty
```
(https://www.puttygen.com/download.php?val=4)
```sh
git-bash.exe
ls -l 3packer.sh 3packer
cp 3packer/Vagrantfile 3packer/vagrantup.sh 3packer/vagrantssh.sh .
source 3packer/shortcut.sh
ssh-keygen.exe -t rsa
cp $HOME/.ssh/id_rsa.pub 3packer/authorized_keys
```
PuTTYgen => Conversion => Import key id_rsa => Save private key id_rsa.ppk

Pageant => Add key id_rsa.ppk
```sh
git-bash.exe
source 3packer.sh /c/debian-10-amd64-DVD-1.iso
source vagrantup.sh
```
Copie des clés :
```sh
vagrant provision --provision-with id_rsa
```
Installation en ssh :
```sh
source vagrantssh.sh
passwd
sudo passwd
cd install/<path>
./0install.sh
```
Resolution :

Uncheck View => Auto-resize Guest Display

Login vagrant
```sh
cd install/<path>
./0install install-*-res.sh
```
