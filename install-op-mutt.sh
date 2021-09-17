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
if notDir /home/mutt; then
    /sbin/adduser mutt
fi
user=mutt
home=/home/$user
sudo -u $user mkdir -p $home/tmp

# ---------------------------------------------------------------------------- #
# muttinstrc
# ---------------------------------------------------------------------------- #
if isFile $home/.muttinstrc; then
    source $home/.muttinstrc
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
FOLDER=$home/Mail
PREFIX=$home/.
#PREFIX=$home/  # Pour tester
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
    chown -R $user.$user $FOLDER
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
        echo " sslcertfile /home/mutt/.certs/fetchmail.pem" >>$file
    fi
    if [ -f $home/.fetchmailrc.in ]; then
        cat $home/.fetchmailrc.in >>$file
    fi
    chmod 700 $file
    chown $user.$user $file
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
    if [ -f $home/.procmailrc.in ]; then
        cat $home/.procmailrc.in >>$file
    fi
    chown $user.$user $file
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
push \`grep alias $home/.mailrc | sed 's/"//g' >$home/tmp/alias\`
source $home/tmp/alias

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
    chown $user.$user $file
fi

# ---------------------------------------------------------------------------- #
# mailrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}mailrc
if notFile $file; then
    cat > $file <<EOF
alias moi "$NAME <$MAIL>"
EOF
    if [ -f $home/.mailrc.in ]; then
        cat $home/.mailrc.in >>$file
    fi
    chown $user.$user $file
fi

# ---------------------------------------------------------------------------- #
# gpg
# ---------------------------------------------------------------------------- #
id=`sudo -u $user gpg --list-public-keys --with-colons 2>$log |\
 grep $MAIL | cut -d ':' -f 5`
if [ -n "$id" ]; then
    if notGrep encrypt-to $home/.gnupg/gpg.conf; then
        echo "encrypt-to $id" >>$home/.gnupg/gpg.conf
    fi
fi
