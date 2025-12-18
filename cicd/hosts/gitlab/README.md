# Installation
```sh
make up
make add-ip
vagrant halt
make up
export DOMAIN=local.fr
export IPADDR=`make get-ip`
export GITLAB_ROOT_PASSWORD=minimum8characters
vagrant provision
make ssh-copy-id
make ssh
export DOMAIN=local.fr
sudo /sbin/make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /mnt/nginx/gitlab.$DOMAIN.crt  # gitlab DNS:gitlab.$DOMAIN
docker-compose up -d
```

# Utilisation
http://gitlab.local.fr  # user root pass ${GITLAB_ROOT_PASSWORD}

http://gitlab.local.fr/admin/users/new

http://gitlab.local.fr/admin/users/sbeaugrand/edit  # password + sign out + sign in

https://gitlab.local.fr/-/profile/preferences

http://gitlab.local.fr/-/user_settings/ssh_keys  # cat ~/.ssh/id_rsa.pub

# [Création du chroot](../../mps/README.md#create-chroot)

# Construction de l'image docker
```sh
export DOMAIN=local.fr
rsync -a -i --checksum Dockerfile  vagrant@gitlab.$DOMAIN:
rsync -a -i --checksum stable-arm* vagrant@gitlab.$DOMAIN:
find ../debian13/.vagrant -maxdepth 1 -name "libjson*" -exec rsync -a -i --checksum {} vagrant@gitlab.$DOMAIN: \;
find ../debian13/.vagrant -maxdepth 1 -name "libmraa*" -exec rsync -a -i --checksum {} vagrant@gitlab.$DOMAIN: \;
find ../debian13/.vagrant -maxdepth 1 -name "libupm-*" -exec rsync -a -i --checksum {} vagrant@gitlab.$DOMAIN: \;
find ../debian13/.vagrant -maxdepth 1 -name "stable-*" -exec rsync -a -i --checksum {} vagrant@gitlab.$DOMAIN: \;
find ../../makefiles/roles/uncrustify/tasks -name "uncrustify*" -exec rsync -a -i --checksum {} vagrant@gitlab.$DOMAIN: \;
vagrant ssh
docker build -t localhost:5000/debian-dev:1.0.0 .
docker push localhost:5000/debian-dev:1.0.0
```

# Création du runner
https://gitlab.local.fr/groups/new  # group

https://gitlab.local.fr/projects/new  # mps  # group  # no README

http://gitlab.local.fr/group/mps/-/runners/new  # Run untagged jobs
```sh
export DOMAIN=local.fr
docker exec -it gitlab-runner gitlab-runner register --url https://gitlab.$DOMAIN --clone-url https://gitlab.$DOMAIN --executor docker --docker-image "localhost:5000/debian-dev:1.0.0" --token ...
```
```sh
sudo vi /mnt/gitlab-runner/config.toml +/privileged
```
```yml
privileged = true
cap_add = ["SYS_CHROOT"]
```
```sh
sudo vi /mnt/gitlab-runner/config.toml +1
```
```yml
concurrent = 2
```

# Git push du projet mps dans group
```sh
git config --global user.name "sbeaugrand"
git config --global user.email "sbeaugrand@toto.fr"
git init --initial-branch=main
export DOMAIN=local.fr
git remote add origin [git@gitlab.$DOMAIN:2222]:group/mps.git
git add .
git commit -m "Initial commit"
git push --set-upstream origin main
```

# Optionnel

## Disk resize
```sh
# sudo virsh blockresize gitlab_gitlab /data/libvirt/gitlab_gitlab.img 64G
vagrant ssh
# lsblk
# sudo apt install fdisk
# sudo growpart /dev/vda 3
df
sudo /sbin/lvextend -r -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```

## Webhook git-pull
http://gitlab.local.fr/admin/application_settings/network<br/>
Outbound requests `Allow requests to the local network from webhooks and integrations`

http://gitlab.local.fr/-/user_settings/personal_access_tokens

Name `ro`<br/>
Scopes `read_repository, read_api`

```sh
vagrant ssh
cd git-pull
docker build -t localhost:5000/git-pull:1.0.0 .
docker push localhost:5000/git-pull:1.0.0
export DOMAIN=local.fr
docker-compose up -d
curl -d "" http://192.168.121.171:8000/group/mps?token=glpat-...
```
http://gitlab.local.fr/group/mps/-/hooks<br/>
URL `http://192.168.121.171:8000/group/mps?token=glpat-...`<br/>
Trigger `Push events`<br/>
SSL verification `disabled`

## Artefacts depuis le projet libjsonrpccpp

http://gitlab.local.fr/group/mps/-/settings/ci_cd

### Variables<br/>
Environments `*`<br/>
Key `PRIVATE_TOKEN`<br/>
Value `glpat-...`
