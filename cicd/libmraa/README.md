# Build libmraa

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
 vagrant1> sudo apt install ./libmraa/build/*.deb
```
