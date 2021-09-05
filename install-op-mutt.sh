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
# .muttinstrc
# ---------------------------------------------------------------------------- #
if isFile $home/.muttinstrc; then
    source $home/.muttinstrc
else
    cat <<EOF

.muttinstrc example :

NAME="Toto"
MAIL=toto@toto.fr
MAIL2=
SERVER=pop.toto.fr
PORT=995
PROTO=POP3
USER=toto
PASS=motdepasse
SMTP=smtp://smtp.toto.fr
SMTP2=
SSLFP=
SSLCP=
FOLDER=$home/Mail
PREFIX=$home/.
#PREFIX=$home/  # Pour tester

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
# viewhtmlmsg
# ---------------------------------------------------------------------------- #
file=muttils.tgz

download\
 www.blacktrash.org/hg/muttils/archive/tip.tar.gz muttils.tgz || return 1

if notDir $bdir/muttils; then
    pushd $bdir || return 1
    tar xzf $repo/muttils.tgz --transform 's@^muttils-[^/]*@muttils@'
    popd
fi
if notWhich viewhtmlmsg; then
    pushd $bdir/muttils || return 1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi

# ---------------------------------------------------------------------------- #
# fetchmailrc
# ---------------------------------------------------------------------------- #
file=${PREFIX}fetchmailrc
if notFile $file; then
    cat >$file <<EOF
poll $SERVER proto $PROTO
 user '$USER' pass '$PASS'
 #keep
EOF
    if [ -n "$SSLFP" ]; then
        echo " ssl sslfingerprint \"$SSLFP\"" >>$file
    fi
    if [ -n "$SSLCP" ]; then
        echo " sslcertpath $SSLCP" >>$file
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
:0
* ^From:.*$MAIL.*
envoyes/
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
set record    = =envoyes/
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
macro pager <esc>h <pipe-message>BROWSER=firefox\ viewhtmlmsg\ -s<enter>
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
# octet-stream.sh
# ---------------------------------------------------------------------------- #
file=${PREFIX}octet-stream.sh
if notFile $file; then
    cat >$file <<EOF
#!/bin/bash
ext=\${1##*.}
if   [ "\$ext" = "tar" ]; then
    tar tvf "\$1"
elif [ "\$ext" = "tgz" ]; then
    tar tvzf "\$1"
elif [ "\$ext" = "gz"  ]; then
    \$ext=\${1:0-7:5}
    if [ "\$ext" = ".tar." ]; then
        tar tvzf "\$1"
    else
        zcat "\$1"
    fi
elif [ "\$ext" = "bz2" ]; then
    \$ext=\${1:0-8:5}
    if [ "\$ext" = ".tar." ]; then
        tar tvjf "\$1"
    else
        bzcat2 "\$1"
    fi
fi
EOF
    chmod 755 $file
    chown $user.$user $file
fi

# ---------------------------------------------------------------------------- #
# bashrc
# ---------------------------------------------------------------------------- #
if notGrep mutt ${PREFIX}bashrc; then
    echo "alias mutt='fetchmail -a -m procmail && mutt -y'" \
    >>${PREFIX}bashrc
fi

# ---------------------------------------------------------------------------- #
# mailcap
# ---------------------------------------------------------------------------- #
file=${PREFIX}mailcap
mailcap()
{
    if [ -z "$3" ]; then
        echo "$1; $2; copiousoutput" >>$file
    else
        echo "$1; $2; $3" >>$file
    fi
}

if notFile $file; then
    mailcap "text/html" "w3m -o anchor_color=cyan %s"\
            "nametemplate=%s.html; needsterminal"
    mailcap "application/pdf" "mupdf %s"
    mailcap "application/octet-stream" "${PREFIX}octet-stream.sh %s"
    mailcap "application/x-zip-compressed" "unzip -l %s"
    mailcap "application/x-gzip" "zcat %s"

    mailcap "application/vnd.oasis.opendocument.text" "libreoffice %s"
    mailcap "application/msword" "libreoffice %s"

    mailcap "application/vnd.oasis.opendocument.spreadsheet" "libreoffice %s"
    mailcap "application/vnd.ms-excel" "libreoffice %s"

    mailcap "application/vnd.oasis.opendocument.presentation" "libreoffice %s"
    mailcap "application/vnd.ms-powerpoint" "libreoffice %s"

    officedocument="application/vnd.openxmlformats-officedocument"
    mailcap "$officedocument.wordprocessingml.document" "libreoffice %s"
    mailcap "$officedocument.spreadsheetml.sheet" "libreoffice %s"
    mailcap "$officedocument.presentationml.presentation" "libreoffice %s"

    mailcap "audio/mpeg" "mplayer -quiet %s"
    mailcap "video/x-msvideo" "mplayer -quiet %s"

    mailcap "image/*" "qiv -l %s" " "

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
