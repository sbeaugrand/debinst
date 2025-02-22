# Installation sur armbian
## [Nanopi Neo](https://www.armbian.com/nanopi-neo/)
![Nanopi Neo](https://www.armbian.com/wp-content/uploads/2018/02/nanopineo-300x169.png)
```sh
sha256sum -c Armbian_23.5.2_Nanopineo_bookworm_current_6.1.30_minimal.img.xz.sha
```

## [Orange Pi Zero](https://www.armbian.com/orange-pi-zero/)
![Orange Pi Zero](https://www.armbian.com/wp-content/uploads/2018/02/orangepizero-300x169.png)
```sh
sha256sum -c Armbian_23.5.2_Orangepizero_bookworm_current_6.1.30_minimal.img.xz.sha
```

## [Rockpi S](https://www.armbian.com/rockpi-s/)
![Rockpi S](https://www.armbian.com/wp-content/uploads/2019/11/rockpi-s-300x169.png)
```sh
sha256sum -c Armbian_23.5.2_Rockpi-s_bookworm_current_6.1.32_minimal.img.xz.sha
```

<details>
  <summary>Without boot from the built-in SDNAND</summary>

  ```sh
  df .  # 6,7G needed
  git clone -b v22.08 https://github.com/armbian/build.git armbian-build
  cd armbian-build
  sed -i 's/^IDBLOADER_BLOB/#IDBLOADER_BLOB/' config/sources/families/rockpis.conf
  touch .ignore_changes
  sudo rm ./cache/sources/u-boot/*/idbloader.bin
  sudo apt install debootstrap
  sudo modprobe loop
  systemd-run -p CPUQuota=$((`nproc`*50))% --scope bash -c './compile.sh BOARD=rockpi-s BRANCH=edge BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no CLEAN_LEVEL=, RELEASE=bullseye SKIP_EXTERNAL_TOOLCHAINS=yes EXTRAWIFI=no'
  cd output/images
  ls -l Armbian_22.08.2_Rockpi-s_bullseye_edge_5.19.17_minimal.img
  pv Armbian*.img | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
  ```
</details>

## Installation
```sh
umount /media/$USER/*
pv Armbian*.img.xz | xz -dc - | sudo dd bs=4M oflag=dsync of=/dev/mmcblk0
```
Démarrer sur la Pi
```sh
./find-ip.sh
cd ../cicd/armbian
vi playbook.yml  # enable somfi-pi
keychain ~/.ssh/id_rsa
make ssh user=root [host=pi]  # password: 1234
exit
make ssh-copy-id
make remote
make ssh
cd install/debinst/armbian
make install
sudo reboot
```

## Optionnel

<details>
  <summary>Volume audio</summary>

  ```sh
  make ssh
  cd install/debinst/armbian
  rw
  make volume
  ```
</details>

<details>
  <summary>Infrared receiver - TSOP1838</summary>

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
</details>

<details>
  <summary>Real Time Clock - DS1302</summary>

  ```sh
  make rtc
  ```
</details>

<details>
  <summary>Oled i2c display - SH1106</summary>

  ```sh
  make oled
  ```
</details>

<details>
  <summary>Music player</summary>

  ```sh
  cp install-ex-mps.sh install-pr-mps.sh
  cp mps-ex-toggle.sh mps-pr-toggle.sh
  make mps
  ```
  [Music player](../cicd/mps/README.md)
</details>

<details>
  <summary>Shutter</summary>

  [libmraa](../cicd/libmraa/README.md)
  ```sh
  python3 -c 'import mraa'
  sudo /usr/sbin/rtc `date +%FT%Tw%w`
  make shutter
  ```
  ```sh
  journalctl -u shutter*
  sudo systemctl status shutter.service
  systemctl status shutter-open.timer
  systemctl status shutter-close.timer
  ```
</details>

<details>
  <summary>Cleanup</summary>

  ```sh
  sudo journalctl --rotate
  sudo journalctl --vacuum-time=1s
  ```
</details>

# Comparaison
<br/>

|                                       |Nanopi Neo|Orange Pi Zero|Rockpi S|
|---------------------------------------|----------|--------------|--------|
|Temps pour monter un disque            |45 s      |45 s          |15 s    |
|Le disque résiste au débranchement RJ45|X         |              |X       |
|RJ45 bien orientée                     |X         |              |X       |
|Barrette soudée incluse                |X         |              |X       |
|Volume audio confortable               |X         |X             |        |

<br/>

# Divers

<details>
  <summary>USB to TTL - CH340G</summary>

  ```
  Module           5V  2
   5V _            5V  4
  VCC _            GND 6
  3V3 _|     _____ TX  8
   TX _____ /_____ RX  10
   RX _____/           12
  GND ____________ GND 14
  ```
  Command for RockpiS : `sudo screen /dev/ttyUSB0 1500000`
</details>

<details>
  <summary>Device Tree recompilation</summary>

  ```sh
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
</details>

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
