# Remettre la partition en lecture/écriture
```
sudo rm /var/log
sudo mkdir /var/log
sudo mkdir /var/log/apache2
```
Sur raspios :
```
sudo sed -i 's/ro rootwait/rootwait/' /boot/cmdline.txt
sudo sed -i 's/noatime,ro/noatime/' /etc/fstab
```
Sur armbian :
```
sudo sed -i 's/ ro / rw /' /boot/boot.cmd
sudo sed -i '/tmp/!s/defaults,ro/defaults/' /etc/fstab
```

# Domaine

[No-IP](https://www.noip.com/)

# Certificats

Nat:  80 -> 192.168.x.xx:80

Nat: 443 -> 192.168.x.xx:443
```
export host=mondomaine.net
export mail=toto@free.fr
sudo apt-get -y install python3-pip
sudo python3 -m pip install certbot
sudo systemctl stop apache2
sudo certbot certonly --standalone -d $host -m $mail --rsa-key-size 4096
sudo vi /etc/apache2/sites-enabled/ssl.conf
cat <<EOF
SSLCertificateFile      /etc/letsencrypt/live/$host/cert.pem
SSLCertificateKeyFile   /etc/letsencrypt/live/$host/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/$host/chain.pem
EOF
sudo vi /etc/apache2/apache2.conf +  # ServerName $host
sudo systemctl start apache2
```

# Certbot renew
```
which pip3 || sudo apt-get -y install python3-pip
which certbot || sudo python3 -m pip install certbot
sudo vi /etc/cron.weekly/certbot-renew
 #!/bin/sh
 systemctl stop apache2 >>/var/log/certbot-renew.log
 /usr/local/bin/certbot renew >>/var/log/certbot-renew.log
 systemctl start apache2 >>/var/log/certbot-renew.log
chmod 755 /etc/cron.weekly/certbot-renew
sudo apt install anacron
```

# Fail2ban
```
cd ~/install/debinst
./0install.sh armbian/install-op-fail2ban.sh
```
