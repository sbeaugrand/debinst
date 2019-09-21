#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-03-screen.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# SSH :
# #!/bin/bash
# # in remote .bashrc      : test $TERM = screen && echo -e "\ek`hostname`\e\\"
# # in remote .bash_logout : test $TERM = screen && echo -e "\eklocalhost\e\\"
# # in remote .inputrc     : set bell-style none
# cmd="grep -q screen .bashrc ||"
# cmd="$cmd echo 'test \\\$TERM = screen &&"
# cmd="$cmd echo -e \\\"\\\\ek\\\`hostname\\\`\\\\e\\\\\\\\\\\"' >>.bashrc;"
# cmd="$cmd grep -q localhost .bash_logout ||"
# cmd="$cmd echo 'test \\\$TERM = screen &&"
# cmd="$cmd echo -e \\\"\\\\eklocalhost\\\\e\\\\\\\\\\\"' >>.bash_logout;"
# cmd="$cmd grep -q '^set bell-style none' .inputrc ||"
# cmd="$cmd echo 'set bell-style none' >>.inputrc;"
# eval ssh $1 \"$cmd\"
# ---------------------------------------------------------------------------- #
wmctrl="wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz;"

# ---------------------------------------------------------------------------- #
# screen.desktop
# ---------------------------------------------------------------------------- #
cat >/usr/share/applications/screen.desktop <<EOF
[Desktop Entry]
Name=Screen
Comment=Ligne de commande
Exec=xterm -maximized -title screen -e "$wmctrl screen -t localhost"
Icon=lxterminal
Terminal=false
Type=Application
Categories=TerminalEmulator;System;Utility;
EOF

# ---------------------------------------------------------------------------- #
# .screenrc
# ---------------------------------------------------------------------------- #
if notFile $home/.screenrc ||\
 notGrep "%-w" $home/.screenrc; then
    cat >>$home/.screenrc <<EOF
altscreen on
bindkey ^[[1;2D prev
bindkey ^[[1;2C next
hardstatus alwayslastline "%{= dg} %=%-w%{b ..}%n %t%{= ..}%+w"
defscrollback 5000
termcapinfo xterm* ti@:te@
msgwait 1
# C-a e
bind e stuff 'printf "\eklocalhost\e\\\\"'
EOF
fi

# ---------------------------------------------------------------------------- #
# .Xresources
# ---------------------------------------------------------------------------- #
if notFile $home/.Xresources ||\
 notGrep "xterm\*vt100\*translations:" $home/.Xresources; then
    if ((`xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2` > 1920)); then
        cat >>$home/.Xresources <<EOF
xterm*renderFont: true
xterm*faceName: Monospace
xterm*faceSize: 6
EOF
    elif ((`xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2` == 1920)); then
        cat >>$home/.Xresources <<EOF
xterm*font: 7x14
EOF
    else
        cat >>$home/.Xresources <<EOF
xterm*font: 6x13
EOF
    fi
    cat >>$home/.Xresources <<EOF
xterm*foreground: white
xterm*background: black
xterm*scrollBar: true
xterm*rightScrollBar: true
xterm*vt100*translations: #override <Key>F9: secure()
EOF
    xrdb $home/.Xresources
fi

# ---------------------------------------------------------------------------- #
# /etc/inputrc
# ---------------------------------------------------------------------------- #
if notGrep "^set bell-style none" /etc/inputrc; then
    echo   "set bell-style none" >>/etc/inputrc
fi
