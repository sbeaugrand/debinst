# Pico-sdk
```sh
cd /data/install-build
git clone https://github.com/raspberrypi/pico-sdk
cd pico-sdk

git submodule update --init
sudo apt install picolibc-arm-none-eabi
```

# Picotool
```sh
cd /data/install-build
git clone https://github.com/raspberrypi/picotool.git
cd picotool

mkdir -p build && cd build
cmake .. -DPICO_SDK_PATH=/data/install-build/pico-sdk
make -j`nproc`
sudo make install
```

# Project
```sh
mkdir -p build && cd build
cmake .. -DPICO_SDK_PATH=/data/install-build/pico-sdk -DPICO_BOARD=waveshare_rp2350_eth
make -j`nproc`

sudo picotool load -f main.uf2  # or :
cp main.uf2 /media/$USER/RP2350/  # after BOOT+RESET -RESET -BOOT
nc 192.168.1.200 1000  # with local IP 192.168.1.10
```
