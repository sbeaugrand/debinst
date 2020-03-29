# ---------------------------------------------------------------------------- #
## \file install-03-screen.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# ssh :
#  in remote .bashrc      : test $TERM = screen && echo -e "\ek`hostname`\e\\"
#  in remote .bash_logout : test $TERM = screen && echo -e "\eklocalhost\e\\"
#  in remote .inputrc     : set bell-style none
# ---------------------------------------------------------------------------- #
wmctrl="wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz;"

# ---------------------------------------------------------------------------- #
# screen.desktop
# ---------------------------------------------------------------------------- #
file=/usr/share/applications/screen.desktop
if notFile $file; then
    cat >$file <<EOF
[Desktop Entry]
Name=Screen
Comment=Ligne de commande
Exec=xterm -maximized -title screen -e "$wmctrl SCREENDIR=$home/.screen screen -t localhost"
Icon=lxterminal
Terminal=false
Type=Application
Categories=TerminalEmulator;System;Utility;
EOF
fi

# ---------------------------------------------------------------------------- #
# .screenrc
# ---------------------------------------------------------------------------- #
file=$home/.screenrc
if notGrep "%-w" $file; then
    cat >>$file <<EOF
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
file=$home/.Xresources
if notGrep "xterm\*vt100\*translations:" $file; then
    if ((`xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2` > 1920)); then
        cat >>$file <<EOF
xterm*renderFont: true
xterm*faceName: Monospace
xterm*faceSize: 6
EOF
    elif ((`xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2` == 1920)); then
        cat >>$file <<EOF
xterm*font: 7x14
EOF
    else
        cat >>$file <<EOF
xterm*font: 6x13
EOF
    fi
    cat >>$file <<EOF
xterm*foreground: white
xterm*background: black
xterm*scrollBar: true
xterm*rightScrollBar: true
xterm*vt100*translations: #override <Key>F9: secure()
EOF
    if [ -n "$DISPLAY" ]; then
        xrdb $file
    fi
fi

# ---------------------------------------------------------------------------- #
# /etc/inputrc
# ---------------------------------------------------------------------------- #
file=/etc/inputrc
if notGrep "^set bell-style none" $file; then
    echo "set bell-style none" >>$file
fi
