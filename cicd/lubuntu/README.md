# Enable desktop
```
vi playbook.yml +/desktop
```

# Start and set IP address
```
make up
make add-ip
vagrant halt
make up
vagrant provision
```
