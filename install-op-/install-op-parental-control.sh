# ---------------------------------------------------------------------------- #
## \file install-op-parental-control.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dns=127.0.2.1
ipr=127.0.2.2

# ---------------------------------------------------------------------------- #
# dnscrypt-proxy
# ---------------------------------------------------------------------------- #
if notFile /usr/sbin/dnscrypt-proxy; then
    sudoRoot apt-get -y install dnscrypt-proxy
fi

file=/etc/dnscrypt-proxy/dnscrypt-proxy.toml
if notFile $file; then
    cat >$tmpf <<EOF
# Empty listen_addresses to use systemd socket activation
listen_addresses = []
server_names = ['sfw.scaleway-fr']
blocked_query_response = 'a:$ipr'
cloaking_rules = 'cloaking-rules.txt'

[sources.'parental-control']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/parental-control.md', 'https://download.dnscrypt.info/resolvers-list/v3/parental-control.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/parental-control.md', 'https://download.dnscrypt.net/resolvers-list/v3/parental-control.md']
  cache_file = 'parental-control.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'

[query_log]
  file = '/var/log/dnscrypt-proxy/query.log'

[nx_log]
  file = '/var/log/dnscrypt-proxy/nx.log'

[blocked_names]
  blocked_names_file = 'blocked-names.txt'
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
    sudoRoot systemctl restart dnscrypt-proxy
fi

file=/etc/dnscrypt-proxy/blocked-names.txt 
if notFile $file; then
    cat >$tmpf <<EOF
www.filmstreaming.*
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

file=/etc/dnscrypt-proxy/cloaking-rules.txt 
if notFile $file; then
    cat >$tmpf <<EOF
www.google.*             forcesafesearch.google.com
www.bing.com             strict.bing.com
yandex.ru                familysearch.yandex.ru
=duckduckgo.com          safe.duckduckgo.com
www.youtube.com          restrictmoderate.youtube.com
m.youtube.com            restrictmoderate.youtube.com
youtubei.googleapis.com  restrictmoderate.youtube.com
youtube.googleapis.com   restrictmoderate.youtube.com
www.youtube-nocookie.com restrictmoderate.youtube.com
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

# ---------------------------------------------------------------------------- #
# network manager
# ---------------------------------------------------------------------------- #
connection=`nmcli -g name,type con show | grep -m 1 ethernet | cut -d ':' -f 1`
if [ -z "$connection" ]; then
    logError "ethernet connection not found"
elif ! nmcli con show "$connection" | grep "ipv4.dns:" | grep -q "$dns"; then
    sudoRoot "nmcli con mod '$connection' ipv4.dns '$dns' ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes"
    nmcli con down "$connection" && nmcli con up "$connection"
else
    logWarn "dns already set for $connection"
fi

if LANG=en nmcli general permissions |\
 grep org.freedesktop.NetworkManager.settings.modify.system | grep -q yes; then
    cat >$tmpf <<EOF
[settings.modify.system]
Identity=unix-user:$user
Action=org.freedesktop.NetworkManager.settings.modify.system
ResultAny=no
ResultInactive=no
ResultActive=auth_admin_keep
EOF
    file=/var/lib/polkit-1/localauthority/50-local.d/10-network-manager.pkla
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

# ---------------------------------------------------------------------------- #
# apache
# ---------------------------------------------------------------------------- #
dir=$bdir/blocked-query-response
if notDir $dir; then
    mkdir $dir
fi

file=$dir/index.html
if notFile $file; then
    cat >$file <<EOF
<html>
<head>
</head>
<body>
  <video muted="" loop id="the-king-video">
    <source src="https://jurassicsystems.com/vid/theKing.mp4" type="video/mp4">
  </video>
  <script>
    const theKingVideo = document.getElementById('the-king-video')
    if (theKingVideo != null) {
        theKingVideo.play()
    }
  </script>
  <h1>
    Ahahah, vous n'avez pas dit le mot magique !
  </h1>
</body>
</html>
EOF
fi

file=/etc/apache2/sites-enabled/blocked-query-response.conf
if notFile $file; then
    cat >$tmpf <<EOF
<VirtualHost $ipr:80>
	DocumentRoot $dir
</VirtualHost>
<IfModule mod_ssl.c>
	<VirtualHost $ipr:443>
		DocumentRoot $dir
		SSLEngine on
		SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem
		SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
	</VirtualHost>
</IfModule>
<Directory $dir>
    Require all granted
</Directory>
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
    sudoRoot systemctl restart apache2
fi

# ---------------------------------------------------------------------------- #
# firefox
# ---------------------------------------------------------------------------- #
file=/etc/firefox-esr/firefox-esr.js
if notGrep "network.trr.mode" $file; then
    cp $file $tmpf
    cat >>$tmpf <<EOF

pref("network.trr.mode", 5, locked);
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi
