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
git clone https://github.com/radxa/kernel.git -b stable-4.4-rockpis
export ARCH=arm64
export CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
```

# Modules
```
cd kernel
make rk3308_linux_defconfig
ssh rock@rps uname -r  # 4.4.143-52-rockchip-g7ed61b60d176
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/gpio-ir-recv.ko obj-m=gpio-ir-recv.o
make EXTRAVERSION=-52-rockchip-g7ed61b60d176 LOCALVERSION= drivers/media/rc/ir-nec-decoder.ko obj-m=ir-nec-decoder.o
cp drivers/media/rc/gpio-ir-recv.ko ~/install/debinst/install-op-rockpi/lirc/
cp drivers/media/rc/ir-nec-decoder.ko ~/install/debinst/install-op-rockpi/lirc/
```

# Device tree overlay
```
cp ~/install/debinst/install-op-rockpi/lirc/rockpis-gpio-ir-recv-high-OR-low.dts arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dts
vi arch/arm64/boot/dts/rockchip/overlay/Makefile  # rockpis-gpio-ir-recv.dtbo
make dtbs
cp arch/arm64/boot/dts/rockchip/overlay/rockpis-gpio-ir-recv.dtbo ~/install/debinst/install-op-rockpi/lirc/
```

# Config
```
cd ~/install/debinst
HOST=rps ./install-op-rockpi.sh
ssh rock@rps
cd ~/install/debinst/install-op-rockpi
../0install.sh install-op-lirc.sh
sudo reboot
```
