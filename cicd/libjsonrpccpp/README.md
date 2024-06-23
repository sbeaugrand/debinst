# Build libjsonrpccpp
```sh
make build
make package
```

# Sysroot cross compilation installation
```sh
cd /data
mkdir aarch64-linux-gnu-12 && cd aarch64-linux-gnu-12  # or :
mkdir arm-linux-gnueabihf-12 && cd arm-linux-gnueabihf-12
mkdir usr
user=$USER
host=pi
rsync -a -i $user@$host:/usr/include usr/
rsync -a -i $user@$host:/usr/lib usr/
rsync -a -i $user@$host:/lib ./
cd usr
mkdir local
rsync -a -i $user@$host:/usr/local/include local/
rsync -a -i $user@$host:/usr/local/lib local/
```
```sh
make xbuild
make xpackage
make xdeploy
```
```sh
cd /data
rsync -a -i $user@$host:/usr/include usr/
rsync -a -i $user@$host:/usr/lib usr/
```
