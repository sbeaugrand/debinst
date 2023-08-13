## Installation
```
../../armbian/find-ip.sh
keychain ~/.ssh/id_rsa
make ssh user=root  # password: 1234
locale-gen  # if LC_ALL cannot change locale
exit
make ssh-copy-id
make remote
```
