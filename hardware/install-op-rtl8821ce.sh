cat <<EOF

sudo apt-get install linux-headers-$(uname -r) build-essential dkms git
git clone https://github.com/tomaspinho/rtl8821ce
cd rtl8821ce
sudo ./dkms-install.sh

EOF
