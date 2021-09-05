#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file sslfingerprint.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    SERVER=$1
    PORT=${2:-995}
else
    source ~/.muttinstrc || exit 1
fi

rcFile=~/.fetchmailrc
if [ -f $rcFile ]; then
    path=~/.
else
    path=/etc/ssl/
    rcFile=/etc/fetchmailrc
fi

cat <<EOF

openssl s_client -connect $SERVER:$PORT -showcerts | \
openssl x509 -fingerprint -noout -md5
vi $rcFile  # ssl sslfingerprint
mkdir -p ${path}certs
echo | openssl s_client -connect $SERVER:$PORT -showcerts >>${path}certs/fetchmail.pem
c_rehash ${path}certs
vi $rcFile  # sslcertpath `echo ${path}certs`

EOF
