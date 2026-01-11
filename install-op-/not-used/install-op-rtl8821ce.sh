#FIXME: workaround
cat <<EOF
Todo:

sudo apt-get install dkms
git clone https://github.com/tomaspinho/rtl8821ce
cd rtl8821ce
sudo ./dkms-install.sh
echo "blacklist rtw88_8821ce" | sudo tee -a /etc/modprobe.d/blacklist.conf
sudo reboot

EOF
