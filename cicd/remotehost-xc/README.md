# Sysroot cross compilation installation
```
cd /data
mkdir aarch64-linux-gnu-10  # or :
mkdir arm-linux-gnueabihf-10
cd *-linux-*-10
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
vi host.mk  # SUDOPASS or :
export SUDOPASS=...
cd project4
make build
make test
make HOST=remotehost-xc xpipeline  # or

make HOST=remotehost-xc xbuild
make HOST=remotehost-xc xdeploy
make HOST=remotehost-xc xtest
```
