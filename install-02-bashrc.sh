# ---------------------------------------------------------------------------- #
## \file install-02-bashrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
bashrc()
{
    file=$1
    if [ ! -f $file ]; then
        touch $file
    fi
    notGrep ntpdate $file || return 0
    cat >>$file <<EOF

export PS1='\u:\w> '
export PATH=$home/bin:/usr/local/bin:/usr/bin:/bin:$home/install/debinst/bin:$home/install/bin:.
export LS_OPTIONS=--color
export EMACS_TOOLKIT=x11
export DVDCSS_METHOD=title

alias l='ls'
alias lrt='ls -lrt'
alias ls='ls --color=always'
alias ll='ls -l'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias du='du -h'

alias purge='rm -f *~ *.aux'
alias rpurge='find . -name \*~ -exec rm {} \;'
alias grep='grep --color=auto'
alias rgrep='grep -RI --exclude="*~" --color=auto'
alias rkill='rkill.sh'
alias sortdu=\$'du -b | awk \'{ printf "%12d %s\\\\n", \$1, \$2 }\' | LC_ALL=C sort'

alias kc='TMPDIR=/run/lock keychain --dir /run/lock --nogui ~/.ssh/id_rsa && source /run/lock/.keychain/*-sh'
alias ntpdate='sudo /usr/sbin/ntpdate -u ntp.u-psud.fr'
alias aspire='wget -nd -r -k -p -np'
alias mutt='mutt.sh'
alias gs='gs -dBATCH'
alias halt='/sbin/shutdown now'

test -n "\$DISPLAY" && xset -b
setxkbmap -option "nbsp:none"
last -R | grep boot | head -n 2 | tail -n 1 | sed 's/.*boot/Last:/'
test -d /run/lock/.keychain && source /run/lock/.keychain/*-sh
cd
EOF
    return 0
}

bashrc $home/.bashrc
bashrc /root/.bashrc
