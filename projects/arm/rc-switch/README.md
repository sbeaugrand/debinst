# RC-switch

```sh
curl -OL https://github.com/torvalds/linux/raw/refs/heads/master/tools/spi/spidev_test.c
scp *.py *.c *.dts $USER@pi:
ssh $USER@pi
gcc -o spidev_test spidev_test.c
sudo pip install --root-user-action ignore spidev
```

## Nanopi Neo
```sh
sudo vi /boot/armbianEnv.txt +/overlays +$ +"norm $"  # spi-spidev \n param_spidev_spi_bus=0
```

## Rockpi S
```sh
sudo /usr/sbin/armbian-add-overlay rk3308-spi2-spidev.dts
```

## Tests
```sh
sudo ./spidev_test -v -D /dev/spidev* -s 382253 -p `echo "5e c2 e7" | ./code2data.py`  # code without the first bit
echo "5e c2 e7" | sudo ./rc-switch.py
```
