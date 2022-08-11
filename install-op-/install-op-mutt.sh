# ---------------------------------------------------------------------------- #
## \file install-op-mutt.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Deplacer un ensemble de courriels avec mutt :
#  T ;C? ;d
# Avec creation d'une BAL :
#  T ;C ;d
# ---------------------------------------------------------------------------- #
if [ `whoami` != "root" ]; then
    echo " error: try ./0install.sh --root install-op-mutt.sh"
    return 1
fi

muttUser=mutt
muttHome=/home/$muttUser
if notDir $muttHome; then
    /sbin/adduser mutt || return 1
fi

file=/etc/sudoers.d/mutt
if notFile $file; then
    cat >$file <<EOF
$user ALL=(mutt) ALL
mutt ALL=(root) ALL
EOF
fi

sudo -u $muttUser mkdir -p $muttHome/tmp || return 1

# ---------------------------------------------------------------------------- #
# muttinstrc
# ---------------------------------------------------------------------------- #
if isFile $muttHome/.muttinstrc; then
    source $muttHome/.muttinstrc
else
    cat <<EOF

.muttinstrc example :

NAME="Toto"
MAIL=toto@toto.fr
SERVER=pop.toto.fr
PORT=995
PROTO=POP3
POLL_USER=toto
POLL_PASS=motdepasse
SMTP=smtp://smtp.toto.fr
SSLFP=
FOLDER=$muttHome/Mail
PREFIX=$muttHome/.
#PREFIX=$muttHome/  # Pour tester
MAIL2=
SMTP2=

EOF
    return 1
fi

if notDir $FOLDER; then
    mkdir -p $FOLDER/brouillons/cur
    mkdir -p $FOLDER/brouillons/new
    mkdir -p $FOLDER/brouillons/tmp
    chmod 700 $FOLDER
    chown -R $muttUser.$muttUser $FOLDER
fi

# ---------------------------------------------------------------------------- #
# fetchmailrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}fetchmailrc
if notFile $file; then
    cat >$file <<EOF
set invisible

poll $SERVER proto $PROTO
 timeout 30
 user '$POLL_USER' pass '$POLL_PASS'
 antispam -1
EOF
    if [ -n "$SSLFP" ]; then
        echo " ssl sslfingerprint \"$SSLFP\"" >>$file
        echo " sslcertfile $muttHome/.certs/fetchmail.pem" >>$file
    fi
    if [ -f $muttHome/.fetchmailrc.in ]; then
        cat $muttHome/.fetchmailrc.in >>$file
    fi
    chmod 700 $file
    chown $muttUser.$muttUser $file
fi

# ---------------------------------------------------------------------------- #
# procmailrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}procmailrc
if notFile $file; then
    cat >$file <<EOF
MAILDIR  = $FOLDER
DEFAULT  = \$MAILDIR/recus/
LOGFILE  = \$HOME/.procmail.log
LOCKFILE = \$HOME/.procmail.lock
:0
* ^(Subject|From): "?Cron.*
Cron.1/
EOF
    if [ -f $muttHome/.procmailrc.in ]; then
        cat $muttHome/.procmailrc.in >>$file
    fi
    chown $muttUser.$muttUser $file
fi

# ---------------------------------------------------------------------------- #
# muttrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}muttrc
if notFile $file; then
    cat >$file <<EOF
set realname = "$NAME"
set from     = $MAIL
set smtp_url = $SMTP
push \`grep alias $muttHome/.mailrc | sed 's/"//g' >$muttHome/tmp/alias\`
source $muttHome/tmp/alias

set mbox_type = Maildir
set folder    = $FOLDER
set spoolfile = =recus/
set record    = =recus/
set postponed = =brouillons/
mailboxes \`echo $FOLDER/*\`

set uncollapse_jump = yes
set pager_stop      = yes
set delete          = ask-no
set help            = no
macro browser,index m <toggle-mailboxes><search>brouillons<enter><select-entry><mail>
macro browser q <exit><quit>
macro index   q <change-folder>?<toggle-mailboxes>
macro index   C <enter-command>push<enter><tag-prefix><copy-message>
macro index <Down> <next-entry>
macro index <Up>   <previous-entry>
macro attach w "<pipe-message>w3m -T text/html\n"
macro attach l "<pipe-message>lynx -stdin\n"
EOF
    if [ -n "$MAIL2" ] && [ -n $SMTP2 ]; then
        cat >>$file <<EOF
macro generic,pager <esc>F \
<enter-command>set\ from=$MAIL2<enter>\
<enter-command>set\ smtp_url=$SMTP2<enter>
EOF
    fi
    cat >>$file <<EOF

charset-hook ^iso-8859-1\$ windows-1252
set assumed_charset = windows-1252:iso-8859-1:utf-8
set   folder_format = "%N %f"
set    index_format = "%S %d %5c %-40F %s"
set     date_format = "%d/%m/%Y %H:%M:%S"
set  forward_format = "Tr: %s"

set mark_old = no
set sort     = date
color index brightcyan black ~N
color hdrdefault cyan black
color header brightcyan black X-Face

set mime_forward=yes
set editor = "vim +':set paste'"
bind attach <return> view-mailcap

set crypt_use_gpgme=no
EOF
    chown $muttUser.$muttUser $file
fi

# ---------------------------------------------------------------------------- #
# mailrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}mailrc
if notFile $file; then
    cat > $file <<EOF
alias moi "$NAME <$MAIL>"
EOF
    if [ -f $muttHome/.mailrc.in ]; then
        cat $muttHome/.mailrc.in >>$file
    fi
    chown $muttUser.$muttUser $file
fi

# ---------------------------------------------------------------------------- #
# w3m
# ---------------------------------------------------------------------------- #
file=$muttHome/.w3m/config
if notFile $file; then
    mkdir -p $muttHome/.w3m
    echo "anchor_color cyan" >$file
    chown -R $muttUser.$muttUser $muttHome/.w3m
elif notGrep "anchor_color cyan" $file; then
    sed -i 's/anchor_color .*/anchor_color cyan/' $file
fi

# ---------------------------------------------------------------------------- #
# gpg
# ---------------------------------------------------------------------------- #
id=`sudo -u $muttUser gpg --list-public-keys --with-colons 2>$log |\
 grep $MAIL | cut -d ':' -f 5`
if [ -n "$id" ]; then
    if notGrep encrypt-to $muttHome/.gnupg/gpg.conf; then
        echo "encrypt-to $id" >>$muttHome/.gnupg/gpg.conf
    fi
fi
