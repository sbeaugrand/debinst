#!/bin/bash

# authorized_keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget $PACKER_HTTP_ADDR/authorized_keys ||\
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# sudo
echo "%vagrant ALL=NOPASSWD:ALL" >/etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant
