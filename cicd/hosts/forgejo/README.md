# [Create chroot](../../mps/README.md#create-chroot)

# [Build libraries](../../mps/README.md#build-libs)

# Docker image
```sh
sed '/git/a \ \ \ \ nodejs\\' ../gitlab/Dockerfile >../debian13/.vagrant
cd ../debian13/.vagrant
ls -l `grep COPY Dockerfile | cut -d' ' -f2 | tr '\n' ' '`
docker build -t debian-dev .
cd -
```

# Forgejo
```sh
# https://code.forgejo.org/forgejo-contrib/forgejo-deb#install-with-apt
sudo curl https://code.forgejo.org/api/packages/apt/debian/repository.key -o /etc/apt/keyrings/forgejo-apt.asc
echo "deb [signed-by=/etc/apt/keyrings/forgejo-apt.asc] https://code.forgejo.org/api/packages/apt/debian lts main" | sudo tee /etc/apt/sources.list.d/forgejo.list
sudo apt update
sudo apt install forgejo-sqlite
sudo systemctl disable forgejo
```
http://localhost:3000/

Database type ```SQLite3```<br/>
SSH server port ```3022```<br/>
Enable self-registration<br/>
Disable update checker<br/>
Administrator account settings ```root toto@toto.fr minimum8characters```<br/>

http://localhost:3000/user/settings/appearance

## SSH server
http://localhost:3000/user/settings/keys

```sh
# https://forgejo.org/docs/next/admin/config-cheat-sheet/
sudo vi /etc/forgejo/app.ini +1 +/_SSH  # START_SSH_SERVER = true
sudo systemctl restart forgejo
```
# Runner
https://code.forgejo.org/forgejo/runner/releases

```sh
# https://forgejo.org/docs/latest/admin/actions/runner-installation/#downloading-and-installing-the-binary
cd ~/Downloads
VERSION=12.7.0
curl -O https://code.forgejo.org/forgejo/runner/releases/download/v$VERSION/forgejo-runner-$VERSION-linux-amd64
curl -O https://code.forgejo.org/forgejo/runner/releases/download/v$VERSION/forgejo-runner-$VERSION-linux-amd64.asc
gpg --keyserver hkps://keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
gpg --verify forgejo-runner-$VERSION-linux-amd64.asc forgejo-runner-$VERSION-linux-amd64 && echo "Verified" || echo "Failed"
sudo cp forgejo-runner-$VERSION-linux-amd64 /usr/local/bin/forgejo-runner
sudo chmod 755 /usr/local/bin/forgejo-runner
cd -
make config
```

## Register
```sh
# https://code.forgejo.org/forgejo/runner/src/branch/main/examples/docker-compose
SECRET=`openssl rand -hex 20`
sudo su -c "forgejo forgejo-cli actions register --keep-labels --secret $SECRET" forgejo
forgejo-runner create-runner-file -c build/config.yml --connect --instance http://172.18.0.1:3000 --name runner --secret $SECRET
make
```

# Git push
```sh
# git config --global user.name "sbeaugrand"
# git config --global user.email "sbeaugrand@toto.fr"
git init --initial-branch=main
git remote add origin ssh://forgejo@localhost:3022/root/mps.git
git add .
git commit -m "Initial commit"
git push --set-upstream origin main
```

http://localhost:3000/root/mps/actions

http://localhost:3000/root/-/packages/generic/mps
