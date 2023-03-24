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
    if notGrep "ntpdate" $file; then
        cat >>$file <<EOF

export PS1='\u:\w> '
export PATH=$home/.local/bin:/usr/local/bin:/usr/bin:/bin:$home/install/debinst/bin:$home/install/bin:.
export LS_OPTIONS=--color
export EMACS_TOOLKIT=x11
export DVDCSS_METHOD=title
export SCREENDIR=$home/.screen

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
alias rgrep='grep -RI --exclude-dir=build --color=auto'
alias rfind='find . -type d -name build -prune -o -name'
alias rkill='rkill.sh'
alias sortdu=\$'du -b | awk \'{ printf "%12d %s\\\\n", \$1, \$2 }\' | LC_ALL=C sort'

alias kc='TMPDIR=/run/lock keychain --dir /run/lock --nogui ~/.ssh/id_rsa && source /run/lock/.keychain/*-sh'
alias ntpdate='sudo /usr/sbin/ntpdate -u ntp.u-psud.fr'
alias aspire='wget -nd -r -k -p -np'
alias mutt='mutt.sh'
alias goto='goto.sh'
alias dns='dns.sh'
alias hotspot='hotspot.sh'
alias gs='gs -dBATCH'
alias last='last -R | grep boot | head -n 2 | tail -n 1 | sed "s/.*boot/Last:/"'
alias halt='/sbin/shutdown now'

bind '"\e[1;5A": history-search-backward'
bind '"\e[1;5B": history-search-forward'
bind 'set bell-style none'
test -n "\$DISPLAY" && xset -b
setxkbmap -option "nbsp:none"
test -d /run/lock/.keychain && kc
cd
EOF
    fi
}

if [ -n "$muttUser" ]; then
    bashrc $muttHome/.bashrc
else
    bashrc $home/.bashrc
fi
