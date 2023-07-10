# Example 1: build on vm, deploy on remote
```
make ssh-copy-id
make mount
cd ../project4
make rbuild
make rpackage
make rdeploy HOST=remotehost
cd -
make umount
```

# Example 2: tests with remote
```
make ssh-copy-id
make mount
cd ../project4
make build
make HOST=remotehost rbuild
make HOST=remotehost rtest
cd -
make umount
```
