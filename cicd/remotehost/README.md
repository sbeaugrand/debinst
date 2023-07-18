# Installation
```
vi host.mk
make ssh-copy-id
make remote
```

# Example 1: build on vm, deploy on remote
```
cd ../project4
make rbuild
make rpackage
make rdeploy HOST=remotehost
```

# Example 2: tests with remote
```
cd ../project4
make build
make HOST=remotehost rbuild
make HOST=remotehost rtest
```

# Example 3: to test with vm
```
make mount
cd ../project4
make build
make HOST=remotehost rbuild
make HOST=remotehost rtest
cd -
make umount
```
