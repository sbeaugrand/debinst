# ---------------------------------------------------------------------------- #
## \file install-op-phpmyadmin-extra.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
addServer()
{
    file=$1
    ip=$2
    if notFile $file; then
        cat >$file <<EOF
<?php
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['host'] = '$ip';
\$cfg['Servers'][\$i]['connect_type'] = 'tcp';
\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['extension'] = 'mysql';
\$i++;
EOF
    fi
}

addServer /etc/phpmyadmin/conf.d/118.php 192.168.1.118
addServer /etc/phpmyadmin/conf.d/010.php 10.0.50.10
service apache2 restart
