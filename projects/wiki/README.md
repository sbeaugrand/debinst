# Domaine

[No-IP](https://www.noip.com/)

# Certificats

Nat:  80 -> 192.168.x.xx:80
Nat: 443 -> 192.168.x.xx:443
```
export host=mondomaine.net
export mail=toto@free.fr
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
echo "0 5 1 * * root /usr/local/bin/certbot renew --apache >>/var/log/certbot-renew.log" | sudo tee -a /etc/crontab
```
