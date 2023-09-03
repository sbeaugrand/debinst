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
    if notGrep "hotspot" $file; then
        cat >>$file <<EOF

export DVDCSS_METHOD=title

alias dns='dns.sh'
alias goto='goto.sh'
alias mutt='mutt.sh'
alias rkill='rkill.sh'
alias hotspot='hotspot.sh'
alias scan2pdf='scan2pdf.sh'
alias tuxguitar='tuxguitar.sh'

cd
EOF
    fi
}

if [ -n "$muttUser" ]; then
    bashrc $muttHome/.bashrc
else
    bashrc $home/.bashrc
fi
