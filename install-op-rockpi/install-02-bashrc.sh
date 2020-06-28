# ---------------------------------------------------------------------------- #
## \file install-02-bashrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.bashrc

notGrep MP3DIR $file || return 0

cat >>$file <<EOF

export PS1='\u@\h:\w> '
alias l='ls'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias rw='sudo mount -o rw,remount /'
alias ro='sudo mount -o ro,remount /'
export MP3DIR=/mnt/mp3/mp3
EOF
