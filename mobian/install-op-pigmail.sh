# ---------------------------------------------------------------------------- #
## \file install-op-pigmail.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
project=pigmail

file=$home/.local/share/applications/pigmail.desktop
if notFile $file; then
    cat >$file <<EOF
[Desktop Entry]
Name=Pigmail
Comment=Python Imap Gtk Mail
Icon=$home/.local/share/icons/pigmail.svg
Exec=env GTK_THEME=Adwaita:dark $idir/mobian/pigmail/pigmail.py
Type=Application
Terminal=false
Categories=Network;
Path=$idir/mobian/pigmail
EOF
fi

dir=$home/.local/share/icons
if notDir $dir; then
    mkdir -p $dir
fi

file=$dir/pigmail.svg
if notFile $file; then
    $idir/mobian/pigmail/icon.py $file
fi

file=$project/user-pr-config.py
if notFile $file; then
    cat <<EOF

Todo:

cp $project/user-ex-config.py $file
vi $file  # set IMAP_HOST and IMAP_USER

EOF
    return 1
fi

imapHost=`grep 'IMAP_HOST =' $file | cut -d '=' -f 2`
imapUser=`grep 'IMAP_USER =' $file | cut -d '=' -f 2`
cat <<EOF

Todo:

python3 -m keyring set $imapHost $imapUser

EOF
