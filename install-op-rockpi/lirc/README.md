# VMA317 (1838) infrared receiver on RockpiS with kernel 4.4.143-52-rockchip

* [Infrared receiver](https://www.velleman.eu/products/view/?id=435548)
* [Remote control](https://joy-it.net/en/products/SBC-IRC01)

# Diagram

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

# Compiler
```
sudo apt-get install device-tree-compiler
sudo apt-get install u-boot-tools
git clone https://github.com/radxa/kernel.git -b stable-4.4-rockpis
wget https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
sudo tar xvf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz -C /usr/local/  # https://wiki.radxa.com/RockpiS/dev/kernel-4.4
export ARCH=arm64
export CROSS_COMPILE=/usr/local/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
```

# Modules
```
cd kernel
make rk3308_linux_defconfig
ssh rock@rps uname -r  # 4.4.143-52-rockchip-g7ed61b60d176
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/gpio-ir-recv.ko obj-m=gpio-ir-recv.o
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/ir-nec-decoder.ko obj-m=ir-nec-decoder.o
scp drivers/media/rc/gpio-ir-recv.ko rock@rps:/home/rock/install/debinst/install-op-rockpi/lirc/
scp drivers/media/rc/ir-nec-decoder.ko rock@rps:/home/rock/install/debinst/install-op-rockpi/lirc/
```

# Device tree overlay
```
cp ~/install/debinst/install-op-rockpi/lirc/rockpis-gpio-ir-recv.dts arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dts
vi arch/arm64/boot/dts/rockchip/overlay/Makefile  # rockpis-gpio-ir-recv.dtbo
make dtbs
scp arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dtbo rock@rps:/home/rock/install/debinst/install-op-rockpi/lirc/rockpis-gpio-ir-recv.dtbo
```

# Config
```
ssh rock@rps
cd ~/install/debinst/install-op-rockpi
../0install.sh install-op-lirc.sh
sudo reboot
```
