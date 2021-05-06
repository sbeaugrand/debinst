mailUrl=
mailUser=
mailPass=
smsUrl=https://smsapi.free-mobile.fr/sendmsg
smsUser=
smsPass=

file=/etc/procmailrc
if notFile $file; then
    cat >$file <<EOF
:0
* ^From:.*Jules Cesar
* ^Subject:.*Te laisse pas faire
| /usr/bin/sms.sh

:0
/dev/null
EOF
fi
