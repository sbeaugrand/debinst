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
