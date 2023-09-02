# Build on docker
```
docker build -t camotics .
docker run -v $PWD:/pwd camotics cp CAMotics/camotics_1.3.0_amd64.deb /pwd/
docker container prune
docker rmi camotics
docker rmi debian:stable-slim
```

# Build on localhost
```
sudo apt install equivs
equivs-build camotics-control
sudo apt install ./camotics-build-deps_1.0_all.deb

git clone https://github.com/CauldronDevelopmentLLC/cbang
git clone https://github.com/CauldronDevelopmentLLC/CAMotics
scons -C cbang v8_compress_pointers=false
export CBANG_HOME=$PWD/cbang
cd CAMotics
sed -i 's/libssl1.1/libssl3/' SConstruct
scons
scons package

sudo apt install ./camotics_1.3.0_amd64.deb
sudo apt remove camotics-build-deps
sudo apt autoremove
```
