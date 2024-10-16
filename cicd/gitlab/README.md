# Installation
```sh
cd ../hosts/ubuntu2404
make up
sudo apt remove ansible
pip install ansible  # https://github.com/void-linux/void-packages/issues/47483
vagrant ssh
sudo mkdir -p /mnt
sudo mkdir /mnt/registry
sudo mkdir /mnt/gitlab-config /mnt/gitlab-data /mnt/gitlab-logs
sudo mkdir /mnt/gitlab-runner
export GITLAB_ROOT_PASSWORD=minimum8characters
docker-compose up -d
```

# Utilisation
```sh
sudo vi /etc/hosts +
192.168.121.124 gitlab.toto.fr
```
http://gitlab.toto.fr  # user root pass ${GITLAB_ROOT_PASSWORD}

http://gitlab.toto.fr/admin/users/new

http://gitlab.toto.fr/admin/users/sbeaugrand/edit  # password + sign out + sign in

http://gitlab.toto.fr/-/user_settings/ssh_keys

# Creation d'un runner pour le projet mps dans group
```sh
scp libjsonrpccpp*_amd64.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp libmraa*_amd64.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp libupm*_amd64.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp libjsonrpccpp*_armhf.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp libmraa*_armhf.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp libupm*_armhf.deb vagrant@gitlab.toto.fr:/home/vagrant/
scp stable-armhf.tar.zst vagrant@gitlab.toto.fr:/home/vagrant/
vagrant ssh
sudo apt install docker-buildx
docker build -t localhost:5000/debian-dev:1.0.0 .
docker push localhost:5000/debian-dev:1.0.0
```
http://gitlab.toto.fr/group/mps/-/runners/new  # Run untagged jobs
```sh
docker exec -it gitlab-runner gitlab-runner register --url http://gitlab.toto.fr --executor docker --docker-image "localhost:5000/debian-dev:1.0.0" --token ...
```

# Git push du projet mps dans group
```sh
git config --global user.name "sbeaugrand"
git config --global user.email "sbeaugrand@toto.fr"
git init --initial-branch=main
git remote add gitlab [git@gitlab.toto.fr:2222]:group/mps.git
git add .
git commit -m "Initial commit"
git push --set-upstream gitlab main
```
