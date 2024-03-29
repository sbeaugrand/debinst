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
alias lrt='ls -lrt'
alias ls='ls --color=always'
alias ll='ls -l'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias du='du -h'

alias rw='sudo mount -o rw,remount /'
alias ro='sudo mount -o ro,remount /'
export MP3DIR=/mnt/mp3
export LC_ALL=C
export XMMS_PATH=unix:///run/xmms-ipc-ip

alias volet='sudo /home/$USER/install/debinst/projects/arm/sompi/sompi.sh'
EOF
