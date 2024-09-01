# Start and set IP address
```sh
make up
make add-ip
vagrant halt
make up
vagrant provision
make ssh-copy-id  # for rsync in pbuilder.yml
```
