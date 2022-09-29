# ---------------------------------------------------------------------------- #
## \file install-op-phpmyadmin-base.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=4.9.1
dir=phpMyAdmin-$version-all-languages
file=$dir.zip
download https://files.phpmyadmin.net/phpMyAdmin/$version/$file || return 1
untar $file || return 1

root=/usr/share/phpmyadmin
if notDir $root; then
    cp -a $bdir/$dir $root
fi

serverName=phpmyadmin
file=/etc/apache2/sites-enabled/$serverName.conf
if notFile $file; then
    cat >$file <<EOF
<VirtualHost *:80>
    ServerName $serverName
    DocumentRoot $root
    <Directory   $root>
        Options FollowSymLinks
        Require all granted
        Require host $serverName
    </Directory>
    AddDefaultCharset utf-8
    php_admin_value error_reporting 8191
    php_admin_value display_errors On
    LogLevel  debug
    ErrorLog  /var/log/$serverName-error.log
    CustomLog /var/log/$serverName-access.log common
</VirtualHost>
EOF
    if ! /sbin/a2query -q -m php7.3; then
        logError "apache2 php mod is not enabled"
        if /sbin/a2query -q -m mpm_event; then
            /sbin/a2dismod mpm_event
        fi
        /sbin/a2enmod php7.3
    fi
    /sbin/service apache2 restart
fi

if notGrep "$serverName" /etc/hosts; then
    echo "127.0.0.1 $serverName" >>/etc/hosts
fi
