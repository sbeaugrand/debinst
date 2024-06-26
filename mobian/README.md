# Installation sur mobian
```sh
gzip -k -d mobian-pinephone-phosh-20220116.img.gz
umount /media/$USER/*
pv mobian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer King's Cross sur PinePhone
```sh
debian> ./ipforward.sh
mobian$ echo "nameserver 212.27.40.240" | sudo tee /etc/resolv.conf
mobian$ echo "nameserver 212.27.40.241" | sudo tee /etc/resolv.conf
mobian$ sudo ip route add default via 10.66.0.2
mobian$ sudo apt update
mobian$ sudo apt install openssh-server
debian> make rsync
debian> make ssh
sudo su
passwd
exit
cd install/debinst/mobian
sudo apt install make
make install
```

## Carnet d'adresse
```sh
make contacts
```

# Sharing internet from your PC via USB with nftables
```sh
make ssh
ipf
```
See also: [mobian networking](https://wiki.mobian-project.org/doku.php?id=networking)

# X11 forwarding example to configure mobile data connection
```sh
make xssh
mobian@mobian:~$ sudo cp .Xauthority /root/
mobian@mobian:~$ sudo GDK_BACKEND=x11 nm-connection-editor
```

# Récupération des photos et mms
```sh
rsync -ri mobian@mobian:/home/mobian/Images/ Images/
rsync -ri mobian@mobian:/home/mobian/.local/share/chatty/mms/ mms/
```

# Unable to receive SMS messages
```sh
mmcli -m any --messaging-list-sms
mmcli -m 0 --sms 2
mmcli -m 0 --messaging-delete-sms=2
```

# There is no support for seperate internet and MMS APNs
https://gitlab.gnome.org/GNOME/gnome-control-center/-/issues/1460<br/>
https://gitlab.com/kop316/mmsd/-/issues/5<br/>
https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/958

# Licence CeCILL 2.1

Copyright Sébastien Beaugrand

Ce logiciel est régi par la licence CeCILL soumise au droit français et
respectant les principes de diffusion des logiciels libres. Vous pouvez
utiliser, modifier et/ou redistribuer ce programme sous les conditions
de la licence CeCILL telle que diffusée par le CEA, le CNRS et l'INRIA
sur le site "http://www.cecill.info".

En contrepartie de l'accessibilité au code source et des droits de copie,
de modification et de redistribution accordés par cette licence, il n'est
offert aux utilisateurs qu'une garantie limitée. Pour les mêmes raisons,
seule une responsabilité restreinte pèse sur l'auteur du programme, le
titulaire des droits patrimoniaux et les concédants successifs.

A cet égard l'attention de l'utilisateur est attirée sur les risques
associés au chargement, à l'utilisation, à la modification et/ou au
développement et à la reproduction du logiciel par l'utilisateur étant
donné sa spécificité de logiciel libre, qui peut le rendre complexe à
manipuler et qui le réserve donc à des développeurs et des professionnels
avertis possédant des connaissances informatiques approfondies. Les
utilisateurs sont donc invités à charger et tester l'adéquation du
logiciel à leurs besoins dans des conditions permettant d'assurer la
sécurité de leurs systèmes et ou de leurs données et, plus généralement,
à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.

Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
pris connaissance de la licence CeCILL, et que vous en avez accepté les
termes.
