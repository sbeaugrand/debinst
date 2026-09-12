#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mutt.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note pop.free.fr unable to get issuer certificate
##       curl -O https://sectigo.tbs-certificats.com/SectigoPublicServerAuthenticationCADVR36.crt
##       sudo cp SectigoPublicServerAuthenticationCADVR36.crt /usr/share/ca-certificates/
##       sudo dpkg-reconfigure ca-certificates
##       openssl verify ~/.certs/fetchmail.pem  # OK
##       fetchmail -a -m procmail --sslcertfile=.certs/fetchmail.pem --sslcertpath=/usr/lib/ssl/certs
# ---------------------------------------------------------------------------- #
keyfile=~mutt/.fetchmailrc.key
 rcfile=~mutt/.fetchmailrc

if [ `whoami` != "mutt" ]; then
    cat $XAUTHORITY | sudo -u mutt tee ~mutt/.Xauthority >/dev/null
    sudo XAUTHORITY=~mutt/.Xauthority -u mutt -i $0 $*
    exit $?
fi

export PYTHONPATH=/usr/lib/python2.7/site-packages  # viewhtmlmsg

# ---------------------------------------------------------------------------- #
# ifup
# ---------------------------------------------------------------------------- #
intf=`ip -4 a | grep "inet 192" | awk '{ print $NF }'`
if [ -z "$intf" ]; then
    intf=`cat /proc/net/dev | awk -F ":" '{ print $1 }' | grep "^enp"`
    /sbin/ifup $intf
    ifup=$?
else
    ifup=0
fi

# ---------------------------------------------------------------------------- #
# unskip
# ---------------------------------------------------------------------------- #
cur=`date +%m`
if [ -f $keyfile ]; then
    old=`cat $keyfile`
else
    old=0
fi
if [ $cur != $old ] && grep "^skip " $rcfile; then
    mv $rcfile $rcfile.bak
    sed 's/^skip /poll /' $rcfile.bak >$rcfile
    chmod 700 $rcfile
    skip=0
else
    skip=1
fi

# ---------------------------------------------------------------------------- #
# fetchmail
# ---------------------------------------------------------------------------- #
fetchmail -a -m procmail

# ---------------------------------------------------------------------------- #
# ifdown
# ---------------------------------------------------------------------------- #
if [ $ifup = 1 ]; then
    echo -n "ifdown ? (O/n) "
    read ret
    if [ "$ret" != n ]; then
        /sbin/ifdown $intf
    fi
fi

# ---------------------------------------------------------------------------- #
# mutt
# ---------------------------------------------------------------------------- #
\mutt -y

# ---------------------------------------------------------------------------- #
# skip
# ---------------------------------------------------------------------------- #
if [ $skip = 0 ]; then
    mv $rcfile.bak $rcfile
    echo $cur >$keyfile
fi
