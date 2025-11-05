
<details>
  <summary><s>Build libjsonrpccpp with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libjsonrpccpp/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libjsonrpccpp-common0 libjsonrpccpp-client0 libjsonrpccpp-stub0 libjsonrpccpp-server0 libjsonrpccpp-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>

<details>
  <summary><s>Build libmraa with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libmraa/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libmraa2 libmraa-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>

<details>
  <summary><s>Build with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12 && make up && cd -
  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> sudo apt install ./libupm/build/*.deb

  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> dpkg-scanpackages . /dev/null >Packages
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libupm-lcd2 libupm-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'
  ```
</details>

<details>
  <summary><s>Release mps with pbuilder</s></summary>

  ```console
  localhost> cd ../hosts/debian12
  localhost> vagrant ssh
   vagrant1> cd ~/pbuilder/*_result
   vagrant1> python3 -m http.server
   vagrant2> sudo apt install libmpdclient-dev liblirc-dev
   vagrant2> cd ~/pbuilder/*_result
   vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libmpdclient-dev liblircclient-dev' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'

  localhost> sudo apt install libmpdclient-dev liblirc-dev
  localhost> make BUILDER=pbuilder build
  localhost> make BUILDER=pbuilder package

  localhost> make BUILDER=pbuilder rbuild
  localhost> make BUILDER=pbuilder rpackage
  localhost> make BUILDER=pbuilder rxpackage OPTS='-e ARCH=armhf'
   vagrant2> cp -av libmraa2_2.2.0-1_armhf.deb libupm-lcd2_2.0.0-1_armhf.deb libjsonrpccpp-client0_1.4.1-1.0_armhf.deb libjsonrpccpp-common0_1.4.1-1.0_armhf.deb libjsonrpccpp-server0_1.4.1-1.0_armhf.deb mps_1.0.0_armhf.deb /vagrant/.vagrant
  localhost> user=$USER
  localhost> host=pi
  localhost> scp .vagrant/*.deb $user@$host:/tmp/
  localhost> ssh $user@$host
   remotepi> cd /tmp
   remotepi> sudo apt reinstall ./*.deb
  ```
</details>
