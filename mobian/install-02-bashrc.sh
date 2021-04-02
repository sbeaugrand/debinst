# ---------------------------------------------------------------------------- #
## \file install-02-bashrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.bashrc

if notGrep debinst $file; then
    cat >>$file <<EOF
alias ll='ls -l'
alias lrt='ls -lrt'
alias ipa='ip -c a'
alias ipf='sudo ip route add default via 10.66.0.2'
alias ipt='sudo /usr/sbin/iptraf -i wwan0 -B -L /run/iptraf.log'
alias ips='/home/mobian/install/debinst/mobian/ips.py'
alias clks='/home/mobian/install/debinst/mobian/clks.sh'
test -n "\$DISPLAY" && export GDK_BACKEND=x11
EOF
fi
