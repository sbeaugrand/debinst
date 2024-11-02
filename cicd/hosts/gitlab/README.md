# Installation
```sh
make up
make add-ip
vagrant halt
make up
sudo apt remove ansible
pip install ansible  # https://github.com/void-linux/void-packages/issues/47483
vagrant provision
sudo vi /etc/hosts +  # 192.168.121.171 gitlab.local.fr
make ssh-copy-id
make ssh
export DOMAIN=local.fr
export GITLAB_ROOT_PASSWORD=minimum8characters
docker-compose up -d
```

# Utilisation
http://gitlab.local.fr  # user root pass ${GITLAB_ROOT_PASSWORD}

http://gitlab.local.fr/admin/users/new

http://gitlab.local.fr/admin/users/sbeaugrand/edit  # password + sign out + sign in

http://gitlab.local.fr/-/user_settings/ssh_keys

# Git push du projet mps dans group
```sh
git config --global user.name "sbeaugrand"
git config --global user.email "sbeaugrand@toto.fr"
git init --initial-branch=main
git remote add gitlab [git@gitlab.local.fr:2222]:group/mps.git
git add .
git commit -m "Initial commit"
git push --set-upstream gitlab main
```

# Création du chroot
```sh
../debian12
vagrant ssh
mkdir ~/sbuild
DIST=stable
ARCH=armhf
mmdebstrap --variant=buildd --architectures=$ARCH $DIST ~/sbuild/$DIST-$ARCH.tar.xz --include=automake,cmake,debhelper,fakeroot,pkg-config,lintian,dose-distcheck,apt-utils,libargtable2-dev,libcurl4-openssl-dev,libjsoncpp-dev,libmicrohttpd-dev,libmpdclient-dev,liblirc-dev /etc/apt/sources.list
```

# Construction de l'image docker
```sh
rsync -a -i --checksum libjsonrpc*   vagrant@gitlab.local.fr:/home/vagrant/
rsync -a -i --checksum libmraa*      vagrant@gitlab.local.fr:/home/vagrant/
rsync -a -i --checksum libupm*       vagrant@gitlab.local.fr:/home/vagrant/
rsync -a -i --checksum stable-armhf* vagrant@gitlab.local.fr:/home/vagrant/
rsync -a -i --checksum Dockerfile    vagrant@gitlab.local.fr:/home/vagrant/
vagrant ssh
sudo apt install docker-buildx
docker build -t localhost:5000/debian-dev:1.0.0 .
docker push localhost:5000/debian-dev:1.0.0
```

# Création du runner
http://gitlab.local.fr/group/mps/-/runners/new  # Run untagged jobs
```sh
docker exec -it gitlab-runner gitlab-runner register --url http://gitlab.local.fr --executor docker --docker-image "localhost:5000/debian-dev:1.0.0" --token ...
```
```sh
sudo vi /mnt/gitlab-runner/config.toml +/privileged
```
```yml
privileged = true
cap_add = ["SYS_CHROOT"]
```

# Disk resize
```sh
sudo virsh blockresize gitlab_gitlab /data/libvirt/gitlab_gitlab.img 64G
vagrant ssh
lsblk
sudo growpart /dev/vda 3
df
sudo lvextend -r -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```
