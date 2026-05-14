# RP2350-ETH
[Waveshare Wiki](https://www.waveshare.com/wiki/RP2350-ETH)

# Pico-sdk
```sh
cd ~/data/tmp/install-build
git clone https://github.com/raspberrypi/pico-sdk
cd pico-sdk

git submodule update --init
sudo apt install picolibc-arm-none-eabi
```

# Picotool
```sh
cd ~/data/tmp/install-build
git clone https://github.com/raspberrypi/picotool.git
cd picotool

mkdir -p build && cd build
cmake .. -DPICO_SDK_PATH=~/data/tmp/install-build/pico-sdk
make -j`nproc`
sudo make install
```

# Project
```sh
mkdir -p build && cd build
cmake .. -DPICO_SDK_PATH=~/data/tmp/install-build/pico-sdk -DPICO_BOARD=waveshare_rp2350_eth
make -j`nproc`

sudo picotool load -f main.uf2  # or :
cp main.uf2 /media/$USER/RP2350/  # after BOOT+RESET -RESET -BOOT
```
