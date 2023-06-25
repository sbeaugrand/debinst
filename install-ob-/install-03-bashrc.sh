# ---------------------------------------------------------------------------- #
## \file install-03-bashrc.sh
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

export LS_OPTIONS=--color
export EMACS_TOOLKIT=x11
export DVDCSS_METHOD=title

alias rkill='rkill.sh'

alias ntpdate='sudo /usr/sbin/ntpdate -u ntp.u-psud.fr'
alias aspire='wget -nd -r -k -p -np'
alias mutt='mutt.sh'
alias goto='goto.sh'
alias dns='dns.sh'
alias hotspot='hotspot.sh'
alias gs='gs -dBATCH'
alias last='last -R | grep boot | head -n 2 | tail -n 1 | sed "s/.*boot/Last:/"'
alias halt='/sbin/shutdown now'

cd
EOF
    fi
}

if [ -n "$muttUser" ]; then
    bashrc $muttHome/.bashrc
else
    bashrc $home/.bashrc
fi
