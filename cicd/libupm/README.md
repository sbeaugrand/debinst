# Build libupm

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
 vagrant1> sudo apt install ./libupm/build/*.deb
```

<details>
  <summary><s>Build with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libupm/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libupm-lcd2 libupm-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>
