# Build libmraa
```sh
make BUILDER=sbuild build
make BUILDER=sbuild package
sudo apt install ./build/*.deb

localhost> cd ../hosts/debian12
localhost> make up
localhost> vagrant ssh
 vagrant1> mkdir ~/sbuild
 vagrant1> ARCH=armhf
 vagrant1> mmdebstrap --variant=buildd --architectures=$ARCH stable ~/sbuild/stable-$ARCH.tar.xz --include=automake,cmake,debhelper,fakeroot,pkg-config,lintian
localhost> make BUILDER=sbuild rbuild
localhost> make BUILDER=sbuild rpackage
localhost> make BUILDER=sbuild rxpackage OPTS='-e ARCH=armhf'
 vagrant1> sudo apt install ./libmraa/build/*.deb
```

<details>
  <summary><s>Build with pbuilder</s></summary>

  ```sh
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libmraa/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libmraa2 libmraa-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>
