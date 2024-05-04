FROM fedora:latest

ARG name
ARG ip

RUN curl -Os http://$ip:8000/robox-$name.patch\
 && dnf -y update\
 && dnf -y install git unzip\
 && git clone https://github.com/lavabit/robox.git\
 && cd robox\
 && git apply ../robox-$name.patch\
 && export TERM=xterm\
 && export HUMAN=toto\
 && touch .credentialsrc\
 && res/providers/providers-v9.sh packer\
 && dnf -y install qemu\
 && ./robox.sh box generic-$name-libvirt-x64