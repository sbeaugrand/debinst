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

# Infrared receiver on RockpiS

* [Infrared receiver](https://www.velleman.eu/products/view/?id=435548)
* [Remote control](https://joy-it.net/en/products/SBC-IRC01)

# Diagram for VMA317 infrared receiver

A NPN transistor inverter circuit is added to have the right pulse/space times.
The inverter implies GPIO_ACTIVE_HIGH configuration instead of GPIO_ACTIVE_LOW.
```
```
```
 3v3             GPIO2_A4               GND   --> RockpiS pins
  |                 |                    |
  O                 O                    O    --> Inverter pins
  |                 |                    |
  |                 \                    |
  |                 / 1k                 |
  |                 \                    |
  |       10k       |     NPN            |
  |------/\/\/\-----+-----\_/------------|
  |                        |             |
  |                        \             |
  |                        / 100k        |
  |                        \             |
  |                        |             |
  O                        O             O    --> VMA317 pins
  |     LED       1k       |             |
  |-----|>|-----/\/\/\-----|             |
  |                        |             |
  |          47k           |      C      |
  |---------/\/\/\---------+-----| |-----|
  |                        |             |
  O                        O             O    --> 1838 pins
  |          100k          |     NPN     |
  |---------/\/\/\---------+-----\_/-----|
  |                               |      |
```

# Diagram for 1838 only
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

# Compiler
```
sudo apt-get install device-tree-compiler
sudo apt-get install u-boot-tools
export ARCH=arm64
export CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
```

# Modules and device tree overlay for radxa kernel
```
git clone https://github.com/radxa/kernel.git -b stable-4.4-rockpis radxa-kernel
cd radxa-kernel
make rk3308_linux_defconfig
ssh rock@rps uname -r  # 4.4.143-52-rockchip-g7ed61b60d176
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/gpio-ir-recv.ko obj-m=gpio-ir-recv.o
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/ir-nec-decoder.ko obj-m=ir-nec-decoder.o
cp drivers/media/rc/gpio-ir-recv.ko ~/install/debinst/install-op-rockpi/lirc/
cp drivers/media/rc/ir-nec-decoder.ko ~/install/debinst/install-op-rockpi/lirc/
cp ~/install/debinst/install-op-rockpi/lirc/rockpis-gpio-ir-recv-high-OR-low.dts arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dts
vi arch/arm64/boot/dts/rockchip/overlay/Makefile  # rockpis-gpio-ir-recv.dtbo
make dtbs
cp arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dtbo ~/install/debinst/install-op-rockpi/lirc/
```

# Modules for armbian kernel 4.4 (not needed for 5.9)
```
git clone https://github.com/armbian/build.git armbian-build
git clone https://github.com/piter75/rockchip-kernel.git -b rockpis-develop-4.4 armbian-kernel
cd armbian-kernel
export user=xxx
ssh $user@rps uname -r  # 4.4.243-rockpis
grep -m1 SUBLEVEL Makefile  # SUBLEVEL = 228
sed -i 's/SUBLEVEL = 228/SUBLEVEL = 243/' Makefile  # or :
find ../armbian-build/patch/kernel/rockpis-legacy -type f -name '*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -N -i
cp ../armbian-build/config/kernel/linux-rockpis-legacy.config .config
make oldconfig
sudo apt-get install libssl-dev
make EXTRAVERSION=-rockpis LOCALVERSION= drivers/media/rc/gpio-ir-recv.ko obj-m=gpio-ir-recv.o
cp drivers/media/rc/gpio-ir-recv.ko ~/install/debinst/install-op-rockpi/lirc/
```

# Config
```
cd ~/install/debinst
HOST=rps ./install-op-rockpi.sh
ssh $user@rps
cd ~/install/debinst/install-op-rockpi
../0install.sh install-op-lirc.sh
sudo reboot
```
