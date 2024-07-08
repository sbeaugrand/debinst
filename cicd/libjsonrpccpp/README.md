# Build libjsonrpccpp
```sh
make build
make package
cd ../hosts/debian12 && make up && cd -
make rbuild
make rpackage
make rxpackage  # or :
make rxpackage OPTS='-e ARCH=armhf'
```

# Install libjsonrpccpp
```sh
cd ../hosts/debian12
vagrant ssh
cd pbuilder/bookworm-arm*_result
cp libjsonrpccpp-client0_1.4.1-1_arm*.deb /vagrant/.vagrant/
cp libjsonrpccpp-common0_1.4.1-1_arm*.deb /vagrant/.vagrant/
cp libjsonrpccpp-dev_1.4.1-1_arm*.deb     /vagrant/.vagrant/
cp libjsonrpccpp-server0_1.4.1-1_arm*.deb /vagrant/.vagrant/
cp libjsonrpccpp-stub0_1.4.1-1_arm*.deb   /vagrant/.vagrant/
exit
user=$USER
host=pi
scp .vagrant/*.deb $user@$host:/run/user/1000/
ssh $user@$host
cd /run/user/1000
sudo apt install ./*.deb
```

# Sysroot cross compilation installation
```sh
cd /data
mkdir aarch64-linux-gnu-12 && cd aarch64-linux-gnu-12  # or :
mkdir arm-linux-gnueabihf-12 && cd arm-linux-gnueabihf-12
mkdir usr
user=$USER
host=pi
rsync -a -i --delete $user@$host:/usr/include usr/
rsync -a -i --delete $user@$host:/usr/lib usr/
rsync -a -i --delete $user@$host:/lib ./
cd usr
mkdir local
rsync -a -i --delete $user@$host:/usr/local/include local/
rsync -a -i --delete $user@$host:/usr/local/lib local/
```
