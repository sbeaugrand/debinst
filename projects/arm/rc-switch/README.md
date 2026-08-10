```console
localhost> curl -OL https://github.com/torvalds/linux/raw/refs/heads/master/tools/spi/spidev_test.c
 rockpi-s> ssh $USER@rockpi
 rockpi-s> rw
localhost> scp *.py *.c *.dts $USER@rockpi:
 rockpi-s> gcc -o spidev_test spidev_test.c
 rockpi-s> sudo /usr/sbin/armbian-add-overlay rk3308-spi2-spidev.dts
 rockpi-s> ro
 rockpi-s> sudo reboot
localhost> ssh $USER@rockpi
 rockpi-s> sudo ./spidev_test -v -D /dev/spidev2.0 -s 400000 -p `echo "5e c2 e7" | ./code2data.py`  # code without the first bit
 rockpi-s> echo "5e c2 e7" | sudo ./rc-switch.py
```
