# ---------------------------------------------------------------------------- #
## \file install-op-fail2ban.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=/etc/fail2ban
if notDir $dir; then
    apt-get -y install fail2ban
fi

if notFile /usr/sbin/iptables; then
    apt-get -y install iptables
fi

file=$dir/jail.d/defaults-debian.conf
if notGrep "apache" $file; then
    cat >>$file <<EOF

[apache-4xx]
enabled  = true
port     = http,https
logpath  = %(apache_access_log)s
findtime = 24h
bantime  = -1
maxretry = 1
EOF
fi

file=$dir/filter.d/apache-4xx.conf
if notFile $file; then
    cat >$file <<EOF
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD).*HTTP.*" 4[0-9][0-9]
EOF
fi

# vi /var/log/apache2/access.log +
# vi /var/log/fail2ban.log +
# sudo iptables -L
# sudo fail2ban-client set apache-4xx unbanip 192.168.0.254
# fail2ban-regex --print-all-matched /var/log/apache2/access.log /etc/fail2ban/filter.d/apache-4xx.conf
