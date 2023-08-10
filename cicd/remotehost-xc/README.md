# Cross compilation example
```
cd project4
make build
make test
make HOST=remotehost-xc SUDOPASS=... xpipeline  # or

make xbuild
make HOST=remotehost-xc SUDOPASS=... xdeploy
make HOST=remotehost-xc xtest
```
