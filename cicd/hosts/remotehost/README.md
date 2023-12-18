# Installation
```sh
vi host.mk  # vm or remote config
make ssh-copy-id
make remote
```

# Example 1: build on vm, deploy on remote
```sh
make mount
cd ../../project4
make rbuild
make rpackage
make rdeploy HOST=remotehost
cd -
make umount
```

# Example 2: tests with remote
```sh
make mount
cd ../../project4
make build
make BHOST=remotehost rbuild
make BHOST=remotehost rtest
cd -
make umount
```

# Example 3: to test with vm
```sh
cd ../lubuntu
make up
cd ../../project4
make build
make BHOST=remotehost rbuild
make BHOST=remotehost rtest
```

# Example 4: tests with remote service
```sh
make mount
cd ../../project6
make build
make BHOST=remotehost rbuild
make BHOST=remotehost rpackage
make BHOST=remotehost rinstall
make HOST=remotehost stest
cd -
make umount
```

# Example 5: to test remote service with vm
```sh
cd ../lubuntu
make up
cd ../../project6
make build
make BHOST=remotehost rbuild
make BHOST=remotehost rpackage
make BHOST=remotehost rinstall
make HOST=remotehost stest
```
