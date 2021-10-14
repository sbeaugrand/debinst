#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-op-django-wiki.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
project=django-wiki
app=wiki
host=mondomaine.net
mail=toto@free.fr

if notFile /usr/sbin/a2enmod; then
    apt-get -y install apache2
fi
if notFile /etc/apache2/mods-available/wsgi.load; then
    apt-get -y install libapache2-mod-wsgi-py3
fi
if notWhich django-admin; then
    python3 -m pip install django
fi
if notDir /usr/lib/python3/dist-packages/bleach; then
    apt-get -y install python3-bleach
fi
if notDir /usr/lib/python3/dist-packages/markdown; then
    apt-get -y install python3-markdown
fi

gitClone https://github.com/bartTC/django-wakawaka.git || return 1
gitClone https://github.com/erwinmatijsen/django-markdownify.git || return 1

dir=$bdir/django-wakawaka
file=$dir/wakawaka/templates/wakawaka/page.html
if notGrep "markdownify" $file; then
    wdir=`pwd`
    pushd $dir || return 1
    git apply $wdir/wakawaka.patch
    popd
fi

# ---------------------------------------------------------------------------- #
# startproject
# ---------------------------------------------------------------------------- #
dir=$idir/projects/wiki/$project/build
if notDir $dir; then
    mkdir $dir
fi
chown $user.www-data $dir
chmod 775 $dir

if notDir $dir/$app; then
    pushd $dir || return 1
    sudo -u $user django-admin startproject $app .
    popd
fi

if notLink $dir/wakawaka; then
    pushd $dir || return 1
    ln -s $bdir/django-wakawaka/wakawaka
    popd
fi

if notLink $dir/markdownify; then
    pushd $dir || return 1
    ln -s $bdir/django-markdownify/markdownify
    popd
fi

# ---------------------------------------------------------------------------- #
# login.html
# ---------------------------------------------------------------------------- #
dir=$idir/projects/wiki/$project/build/templates/registration
file=$dir/login.html
if notFile $file; then
    mkdir -p $dir
    cat >$file <<EOF
<h2>Log In</h2>
<form method="post">
  {% csrf_token %}
  {{ form.as_p }}
  <button type="submit">Log In</button>
</form>
EOF
fi

# ---------------------------------------------------------------------------- #
# urls.py
# ---------------------------------------------------------------------------- #
dir=$idir/projects/wiki/$project/build
file=$dir/$app/urls.py
if notGrep "accounts" $file; then
    cat >>$file <<EOF

from django.urls import path
from django.urls import include

urlpatterns += [
    path('accounts/', include('django.contrib.auth.urls')),
    path('wiki/', include('wakawaka.urls')),
]
EOF
fi

# ---------------------------------------------------------------------------- #
# settings.py
# ---------------------------------------------------------------------------- #
if [ -f config-pr-.sh ]; then
    source config-pr-.sh
fi

dir=$idir/projects/wiki/$project/build
file=$dir/$app/settings.py
if notGrep "markdownify" $file; then

    cat >>$file <<EOF

ALLOWED_HOSTS += ['$host']

INSTALLED_APPS += [
    'wakawaka',
    'markdownify',
]

TEMPLATES[0]['DIRS'] += [os.path.join(BASE_DIR, 'templates')]

LOGIN_REDIRECT_URL = '/wiki'

MARKDOWNIFY = {
    "default": {
        "STRIP": False,
        "WHITELIST_TAGS": [
            'a',
            'abbr',
            'acronym',
            'b',
            'blockquote',
            'em',
            'i',
            'li',
            'ol',
            'p',
            'strong',
            'ul',
            'h1'
        ]
    }
}

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 1
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
EOF
fi

# ---------------------------------------------------------------------------- #
# apache
# ---------------------------------------------------------------------------- #
file=/etc/apache2/sites-enabled/$app.conf
if notFile $file; then
    cat >$file <<EOF
#<VirtualHost _default_:80>
#  ServerName $host
#  Redirect permanent / https://$host
#</VirtualHost>
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
   #ServerName $host
    DocumentRoot $idir/projects/wiki/$project/build/
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
WSGIScriptAlias / $idir/projects/wiki/$project/build/$app/wsgi.py
WSGIPythonPath $idir/projects/wiki/$project/build
<Directory $idir/projects/wiki/$project/build/$app>
  <Files wsgi.py>
    Require all granted
  </Files>
</Directory>
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

cat <<EOF

Todo:

cd $idir/projects/wiki/$project/build
python3 manage.py migrate

sudo chown $user.www-data db.sqlite3
chmod 664 db.sqlite3

python3 manage.py createsuperuser
echo "user='$user'; mail='$mail'; password='1234'" | cat - ../createuser.py | python3 manage.py shell

sudo systemctl reload apache2
firefox http://localhost/$app/
vi README.md  # domain + cert
sudo vi /etc/apache2/sites-enabled/$app.conf  # domain + cert
sudo systemctl reload apache2
firefox http://$host/$app/

EOF
