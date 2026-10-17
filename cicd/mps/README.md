# Build
```sh
make help  # :
```

## Create chroot
<details>
  <summary>Create chroot</summary>

  ```console
  localhost> cd ../hosts/debian13
  localhost> make up
  localhost> make add-ip
  localhost> vagrant halt
  localhost> make up
  localhost> vagrant provision
  localhost> make ssh-copy-id  # for rsync in sbuild.yml
  localhost> vagrant ssh
   vagrant1> mkdir ~/sbuild
   vagrant1> sudo mkdir /temp && sudo chmod 777 /temp
   vagrant1> export TMPDIR=/temp
   vagrant1> DIST=stable
   vagrant1> ARCH=armhf  # nanopi-neo:armhf orange-pi-zero:armhf rockpi-s:arm64
   vagrant1> mmdebstrap --variant=buildd --architectures=$ARCH $DIST ~/sbuild/$DIST-$ARCH.tar.xz --include=cmake,debhelper,fakeroot,help2man,pkg-config,lintian,dose-distcheck,apt-utils,libargtable2-dev,libcurl4-openssl-dev,libjsoncpp-dev,libmicrohttpd-dev,libmpdclient-dev,liblirc-dev,swig,python3-dev
  ```
</details>

## Build libs
[libjsonrpccpp](../libjsonrpccpp/README.md)

[libmraa](../libmraa/README.md)

[libupm](../libupm/README.md)

## Release
```console
 vagrant1> sudo apt install libmpdclient-dev liblirc-dev
localhost> make BUILDER=sbuild rbuild
localhost> make BUILDER=sbuild rpackage
localhost> make BUILDER=sbuild rxpackage OPTS='-e ARCH=armhf'
```

# Cross build

<details>
  <summary>Method 1: sysroot from remote</summary>

  ## Install libs
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
   remotepi> sudo apt install libmpdclient-dev liblirc-dev gcc g++
   remotepi> sudo apt install libgpiod-dev  # optional ds1302 rtc
  ```
  ## Create sysroot
  ```console
  localhost> cd ~/data/tmp
  localhost> mkdir aarch64-linux-gnu-14 && cd aarch64-linux-gnu-14  # or :
  localhost> mkdir arm-linux-gnueabihf-14 && cd arm-linux-gnueabihf-14
  localhost> mkdir usr
  localhost> user=$USER
  localhost> host=pi
  localhost> rsync -a -i --delete --checksum $user@$host:/usr/include usr/
  localhost> rsync -a -i --delete --checksum $user@$host:/usr/lib usr/
  localhost> rsync -a -i --delete --checksum $user@$host:/lib ./
  localhost> sudo ln -sfn ~/data/tmp/aarch64-linux-gnu-14 /usr/gnemul/qemu-aarch64  # or:
  localhost> sudo ln -sfn ~/data/tmp/arm-linux-gnueabihf-14 /usr/gnemul/qemu-arm
  ```
  ## Optional VM sysroot
  ```console
  localhost> cd ../hosts/debian13
  localhost> rsync -a -i --delete --checksum ~/data/tmp/aarch64-linux-gnu-14 .vagrant/  # or :
  localhost> rsync -a -i --delete --checksum ~/data/tmp/arm-linux-gnueabihf-14 .vagrant/
  ```
</details>

<details>
  <summary>Method 2: sysroot from mmdebstrap</summary>

  ```console
   vagrant1> DIST=stable
   vagrant1> ARCH=armhf  # nanopi-neo:armhf orange-pi-zero:armhf rockpi-s:arm64
   vagrant1> cd ~/sbuild
   vagrant1> mkdir -p ../pbuilder
   vagrant1> xz -d -c $DIST-$ARCH.tar.xz | gzip >../pbuilder/$DIST-$ARCH-base.tgz
   vagrant1> python3 -m http.server
   vagrant2> DIST=stable
   vagrant2> ARCH=armhf  # nanopi-neo:armhf orange-pi-zero:armhf rockpi-s:arm64
   vagrant2> SYSROOT=arm-linux-gnueabihf-14  # aarch64-linux-gnu-
   vagrant2> cd ~/sbuild
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist $DIST $ARCH update --extrapackages 'libjsonrpccpp-common0 libjsonrpccpp-client0 libjsonrpccpp-stub0 libjsonrpccpp-server0 libjsonrpccpp-dev libmraa2 libmraa-dev libupm-lcd2 libupm-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
   vagrant2> cd ../pbuilder
   vagrant2> export TMPDIR=/temp
   vagrant2> mmdebstrap --variant=custom --architectures=$ARCH --skip=update,setup,cleanup,tar-in/mknod --setup-hook="tar-in $DIST-$ARCH-base.tgz /" --customize-hook="copy-out /usr/include /vagrant/.vagrant/$SYSROOT/usr/" $DIST /dev/null
   vagrant2> mmdebstrap --variant=custom --architectures=$ARCH --skip=update,setup,cleanup,tar-in/mknod --setup-hook="tar-in $DIST-$ARCH-base.tgz /" --customize-hook="copy-out /usr/lib /vagrant/.vagrant/$SYSROOT/usr/" $DIST /dev/null
  localhost> SYSROOT=arm-linux-gnueabihf-14  # aarch64-linux-gnu-
  localhost> cd .vagrant/$SYSROOT
  localhost> ln -s usr/lib
  localhost> cp -a ../$SYSROOT ~/data/tmp
  ```
</details>

```sh
make xbuild
make xpackage
make xdeploy
```
```sh
make reinstall
```

# [gitlab](../hosts/gitlab/README.md)

# [forgejo](../hosts/forgejo/README.md)

# [Doc](https://github.com/sbeaugrand/mps)

# License CeCILL 2.1

Copyright Sébastien Beaugrand

This software is governed by the CeCILL license under French law and
abiding by the rules of distribution of free software. You can use,
modify and/or redistribute the software under the terms of the CeCILL
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info".

As a counterpart to the access to the source code and rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty and the software's author, the holder of the
economic rights, and the successive licensors have only limited
liability.

In this respect, the user's attention is drawn to the risks associated
with loading, using, modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean that it is complicated to manipulate, and that also
therefore means that it is reserved for developers and experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or
data to be ensured and, more generally, to use and operate it in the
same conditions as regards security.

The fact that you are presently reading this means that you have had
knowledge of the CeCILL license and that you accept its terms.
