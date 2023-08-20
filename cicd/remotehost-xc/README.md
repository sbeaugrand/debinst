# Sysroot cross compilation installation
```
cd /data
mkdir aarch64-linux-gnu-12 && cd aarch64-linux-gnu-12  # or :
mkdir arm-linux-gnueabihf-12 && cd arm-linux-gnueabihf-12
mkdir usr
user=$USER
host=pi
rsync -a -i $user@$host:/usr/include usr/
rsync -a -i $user@$host:/usr/lib usr/
ln -s usr/lib
cd usr
mkdir local
rsync -a -i $user@$host:/usr/local/include local/
rsync -a -i $user@$host:/usr/local/lib local/
```

# Sysroot cross compilation example
```
cd project4
make build
make HOST=remotehost-xc xbit  # or :

make test
make HOST=remotehost-xc xbuild
make HOST=remotehost-xc xinstall
make HOST=remotehost-xc xtest
```

# Sysroot cross build package example
```
cd project8
make build
make HOST=armbian xpipeline  # or :

make test
make HOST=armbian xbuild
make HOST=armbian xpackage
make HOST=armbian xdeploy
make HOST=armbian xtest
```
