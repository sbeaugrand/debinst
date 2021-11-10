# ---------------------------------------------------------------------------- #
## \file install-op-dokuwiki.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
host=mondomaine.net

file=dokuwiki-stable.tgz
download https://download.dokuwiki.org/src/dokuwiki/$file || return 1
if notDir $bdir/dokuwiki; then
    pushd $bdir || return 1
    tar xzf $repo/$file --transform='s,^[^/]*,dokuwiki,' || return 1
    popd
fi

dwdir=/usr/share/dokuwiki
if notDir $dwdir; then
    cp -r $bdir/dokuwiki $dwdir
    if [ -d pages-pr- ]; then
        cp -a pages-pr-/* $dwdir/data/pages/
    else
        echo " warn: pages-pr- not found"
    fi
    chown -R www-data.www-data $dwdir
fi

file=$dwdir/.htaccess
if notFile $file; then
    cp $file.dist $file
    chown www-data.www-data $file
fi

file=$dwdir/data/pages/start.txt
if [ ! -f $file ]; then
    cat >$file <<EOF
===== Titre =====
**Gras**
  * 1
  * 2
  * 3
[[http://beaugrand.chez.com/|lien]]

> seb: Commentaire

[[nouvellePage|Nouvelle page]]
EOF
    chown www-data.www-data $file
fi

# ---------------------------------------------------------------------------- #
# conf
# ---------------------------------------------------------------------------- #
file=$dwdir/conf/acl.auth.php
if notFile $file; then
    cat >$file <<EOF
# acl.auth.php
# <?php exit()?>
# Don't modify the lines above
#
# Access Control Lists
*       @ALL    0
*       @user   8
start   @ALL    0
start   @user   2
EOF
    chown www-data.www-data $file
fi

file=$dwdir/conf/users.auth.php
if notFile $file; then
    cp -a users-pr-auth.php $file
    chown www-data.www-data $file
fi

file=$dwdir/conf/local.php
if notFile $file; then
    cat >$file <<EOF
<?php
\$conf['lang'] = 'fr';
\$conf['license'] = 'cecill-v2-1';
\$conf['superuser'] = '@admin';
\$conf['useacl'] = 1;
EOF
    chown www-data.www-data $file
fi

file=$dwdir/conf/license.local.php
if notFile $file; then
    cat >$file <<EOF
<?php
\$license['cecill-v2-1'] = array(
    'name' => 'CeCILL 2.1 Free Software license',
    'url'  => 'http://www.cecill.info',
);
EOF
    chown www-data.www-data $file
fi

if [ -f config-pr-.sh ]; then
    source config-pr-.sh
fi

# ---------------------------------------------------------------------------- #
# apache
# ---------------------------------------------------------------------------- #
if notDir /usr/share/doc/libapache2-mod-php; then
    apt-get install libapache2-mod-php
fi

if notDir /usr/share/doc/php-xml; then
    apt-get install php-xml
fi

file=/etc/apache2/sites-enabled/dokuwiki.conf
if notFile $file; then
    cat >$file <<EOF
#<VirtualHost _default_:80>
#  ServerName $host
#  Redirect permanent / https://$host
#</VirtualHost>
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
   #ServerName $host
    DocumentRoot /usr/share/dokuwiki/
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile   /etc/ssl/private/ssl-cert-snakeoil.key
   #SSLCertificateFile      /etc/letsencrypt/live/$host/cert.pem
   #SSLCertificateKeyFile   /etc/letsencrypt/live/$host/privkey.pem
   #SSLCertificateChainFile /etc/letsencrypt/live/$host/chain.pem
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>
  </VirtualHost>
</IfModule>
EOF
fi

file=/etc/apache2/mods-enabled/ssl.load
if notLink $file; then
    /usr/sbin/a2enmod ssl
fi

file=/etc/apache2/sites-enabled/000-default.conf
if [ -L $file ]; then
    /usr/sbin/a2dissite 000-default
fi

# ---------------------------------------------------------------------------- #
# backup
# ---------------------------------------------------------------------------- #
file=/etc/crontab
dir=$home/dokuwiki
if notGrep "dokuwiki" $file; then
    cat >>$file <<EOF
0 4 * * * root /bin/bash -c "cp -u $dwdir/data/pages/*.txt $dir/"
1 4 * * * root /bin/bash -c "cp -u $dwdir/acl/users.auth.php $dir/"
EOF
    systemctl restart cron
fi
if notDir $dir; then
    mkdir $dir
fi

# ---------------------------------------------------------------------------- #
# todo
# ---------------------------------------------------------------------------- #
cat <<EOF

Todo:

sudo systemctl reload apache2
firefox http://localhost/dokuwiki/
vi README.md  # domain + cert
sudo vi /etc/apache2/sites-enabled/dokuwiki.conf  # domain + cert
sudo systemctl reload apache2
firefox http://$host/dokuwiki/

EOF
