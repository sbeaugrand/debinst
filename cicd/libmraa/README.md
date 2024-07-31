# Usage
```sh
make build
make package
sudo apt install ./build/*.deb

cd ../hosts/debian12 && make up && cd -
make rbuild
make rpackage
cd ../hosts/debian12
vagrant ssh
vagrant1> sudo apt install ./libjsonrpccpp/build/*.deb

make rxpackage OPTS='-e ARCH=armhf'
vagrant1> cd ~/pbuilder/*_result
vagrant1> python3 -m http.server
vagrant2> cd ~/pbuilder/*_result
vagrant2> dpkg-scanpackages . /dev/null >Packages
vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libmraa2 libmraa-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
```
