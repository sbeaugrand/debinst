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

<details>
  <summary><s>Build with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libjsonrpccpp/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libjsonrpccpp-common0 libjsonrpccpp-client0 libjsonrpccpp-stub0 libjsonrpccpp-server0 libjsonrpccpp-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>

# Sysroot cross compilation

## Install libjsonrpccpp on remote
```console
localhost> cd ../hosts/debian12
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
