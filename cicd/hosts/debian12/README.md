# Start and set IP address
```sh
make up
make add-ip
vagrant halt
make up
vagrant provision
ssh-copy-id vagrant@192.168.121.212  # for rsync in pbuilder.yml
```
