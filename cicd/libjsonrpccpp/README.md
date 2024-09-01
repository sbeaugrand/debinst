# Usage
```sh
make build
make package
sudo apt install ./build/*.deb

cd ../hosts/debian12 && make up && cd -
make rbuild
make rpackage
cd ../hosts/debian12
vagrant ssh
vagrant1> sudo apt install ./libjsonrpccpp/build/*.deb

make rxpackage OPTS='-e ARCH=armhf'
vagrant1> cd ~/pbuilder/*_result
vagrant1> python3 -m http.server
vagrant2> cd ~/pbuilder/*_result
vagrant2> dpkg-scanpackages . /dev/null >Packages
vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libjsonrpccpp-common0 libjsonrpccpp-client0 libjsonrpccpp-stub0 libjsonrpccpp-server0 libjsonrpccpp-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
```

# Sysroot cross compilation

## Install libjsonrpccpp on remote
```sh
cd ../hosts/debian12
vagrant ssh
cp pbuilder/bookworm-arm*_result/*.deb /vagrant/.vagrant/
rm -f /vagrant/.vagrant/*dbgsym*.deb
exit
user=$USER
host=pi
scp .vagrant/*.deb $user@$host:/run/user/1000/
ssh $user@$host
cd /run/user/1000
sudo apt reinstall ./*.deb
```

## Sysroot installation
```sh
cd /data
mkdir aarch64-linux-gnu-12 && cd aarch64-linux-gnu-12  # or :
mkdir arm-linux-gnueabihf-12 && cd arm-linux-gnueabihf-12
mkdir usr
user=$USER
host=pi
rsync -a -i --delete --checksum $user@$host:/usr/include usr/
rsync -a -i --delete --checksum $user@$host:/usr/lib usr/
rsync -a -i --delete --checksum $user@$host:/lib ./
cd usr
mkdir local
rsync -a -i --delete --checksum $user@$host:/usr/local/include local/
rsync -a -i --delete --checksum $user@$host:/usr/local/lib local/
```
