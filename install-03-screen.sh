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

# ---------------------------------------------------------------------------- #
# screen.desktop
# ---------------------------------------------------------------------------- #
dir=$home/.local/share/applications
sudo -u $user mkdir -p $dir
file=$dir/screen.desktop
if notFile $file; then
    cat >$file <<EOF
[Desktop Entry]
Name=Screen
Comment=Ligne de commande
Exec=xterm -T mxterm -e "SCREENDIR=$home/.screen screen"
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
startup_message off
altscreen on
bindkey ^[[1;2D prev
bindkey ^[[1;2C next
hardstatus alwayslastline "%{= dg} %=%-w%{b ..}%n %t%{= ..}%+w"
defscrollback 5000
termcapinfo xterm* ti@:te@
msgwait 1
# C-a e
bind e stuff 'printf "\eklocalhost\e\\\\"'
shelltitle "localhost"
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
xterm*font: 9x15
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
