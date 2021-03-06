# ---------------------------------------------------------------------------- #
## \file install-op-mail2sms.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=install-pr-mail2sms.sh
if ! isFile $file; then
    echo " Todo:"
    echo " cp install-op-mail2sms-ex.sh install-pr-mail2sms.sh"
    echo " vi install-pr-mail2sms.sh"
    return 1
fi
source $file

if notWhich fetchmail; then
    apt-get -y install fetchmail
fi
if notWhich procmail; then
    apt-get -y install procmail
fi

file=/etc/fetchmailrc
if notFile $file; then
    if [ -z "$mailPass" ]; then
        echo -n "password for $mailUser: "
        read mailPass
    fi
    cat >$file <<EOF
set daemon 300
set idfile /run/fetchids
set invisible

poll $mailUrl proto imap timeout 30
     user "$mailUser"
     pass "$mailPass"
     keep
     ssl
     mda /usr/bin/procmail
     antispam -1
EOF
fi

chmod 600 $file
chown fetchmail $file

file=/etc/default/fetchmail
if notGrep '^START_DAEMON=yes' $file; then
    echo "START_DAEMON=yes" >>$file
fi

file=/usr/bin/sms.sh
if notFile $file; then
    cat >$file <<EOF
cat >/run/fetchmail/mel.tmp
cat /run/fetchmail/mel.tmp | mail2sms.py >/run/fetchmail/sms.tmp
curl --get $smsUrl --data "user=$smsUser" --data "pass=$smsPass" --data-urlencode "msg@/run/fetchmail/sms.tmp"
EOF
    chmod 755 $file
fi

file=/usr/bin/mail2sms.py
if notFile $file; then
    cp `basename $file` $file
fi
