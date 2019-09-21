#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file sslfingerprint.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$2" ]; then
    POP=$2
else
    source ~/.muttinstrc
fi
cat <<EOF

openssl s_client -connect $POP:995 -showcerts | \
openssl x509 -fingerprint -noout -md5
vi ~/.fetchmailrc  # ssl sslfingerprint
mkdir -p ~/.certs
echo | openssl s_client -connect $POP:995 -showcerts >>~/.certs/pop3.pem
c_rehash ~/.certs
vi ~/.fetchmailrc  # sslcertpath `echo ~`/.certs

EOF
