# Build libjsonrpccpp

```sh
make BUILDER=sbuild build
make BUILDER=sbuild package
sudo apt install ./build/*.deb
```

# Release

[Create chroot](../mps/README.md#create-chroot)

```console
localhost> make BUILDER=sbuild rbuild
localhost> make BUILDER=sbuild rpackage
localhost> make BUILDER=sbuild rxpackage OPTS='-e ARCH=armhf'
 vagrant1> sudo apt install ./libjsonrpccpp/build/*.deb
```

# Sysroot cross compilation

## Install libjsonrpccpp on remote
```console
localhost> cd ../hosts/debian13
localhost> vagrant ssh
 vagrant1> cp sbuild/*.deb /vagrant/.vagrant/
 vagrant1> rm -f /vagrant/.vagrant/*dbgsym*.deb
localhost> user=$USER
localhost> host=pi
localhost> scp .vagrant/*.deb $user@$host:/tmp/
localhost> ssh $user@$host
 remotepi> cd /tmp
 remotepi> sudo apt reinstall ./*.deb
```

## Sysroot installation
```sh
cd /data
mkdir aarch64-linux-gnu-14 && cd aarch64-linux-gnu-14  # or :
mkdir arm-linux-gnueabihf-14 && cd arm-linux-gnueabihf-14
mkdir usr
user=$USER
host=pi
rsync -a -i --delete --checksum $user@$host:/usr/include usr/
rsync -a -i --delete --checksum $user@$host:/usr/lib usr/
rsync -a -i --delete --checksum $user@$host:/lib ./
```
```sh
cd ../hosts/debian13
rsync -a -i --delete --checksum /data/aarch64-linux-gnu-14 .vagrant/  # or :
rsync -a -i --delete --checksum /data/arm-linux-gnueabihf-14 .vagrant/
vagrant provision  # create symlink in /etc/qemu-binfmt
```
