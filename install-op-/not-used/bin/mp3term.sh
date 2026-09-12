#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mp3term.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
log=~/.mp3log

if [ "$1" = "-n" ]; then
    xterm=n
else
    xterm=o
fi

# ---------------------------------------------------------------------------- #
# installation de l'application pour LXDE
# ---------------------------------------------------------------------------- #
if [ "$1" = "-i" ]; then
    icon=/usr/share/pixmaps/lxmusic.png

    user=`whoami`
    if [ $user != "root" ]; then
        su -c "$0 $*"
        exit $?
    fi

    cat > /usr/share/applications/mp3.desktop << EOF
[Desktop Entry]
Name=MP3
Comment=Multimedia Player
Exec=mp3term.sh
Icon=mp3
Type=Application
Terminal=false
Categories=AudioVideo;Player;
EOF

    convert $icon -font DejaVu-Sans-Bold -pointsize 53 \
        -fill white -annotate +4+44 "MP3" \
        -fill black -annotate +0+40 "MP3" /usr/share/icons/mp3.png
fi

# ---------------------------------------------------------------------------- #
# setInfo
# ---------------------------------------------------------------------------- #
setInfo()
{
    info=`mp3rand.sh -i`
    max=`cat /tmp/mp3rand-i.tmp | wc -l`
    if [ -z "$max" ] || ((max <= 1)); then
        info=$info`echo -e "\n? (O/n) "`
    else
        info=$info`echo -e "\n? (O/n/1-$max) "`
    fi
}

# ---------------------------------------------------------------------------- #
# dialog
# ---------------------------------------------------------------------------- #
dialog()
{
    setInfo
    if [ $xterm = o ]; then
        wd=`echo -e "$info" | \
            awk '{ h++; if (w < length($0)) w=length($0) } END { print w" "h }'`
        ww=`echo "$wd" | cut -d " " -f 1`
        wh=`echo "$wd" | cut -d " " -f 2`
        sw=`xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2`
        sh=`xrdb -symbols | grep DHEIGHT | cut -d '=' -f 2`
        fw=6
        fh=13
        ((xp = (sw - ww * fw) / 2))
        ((yp = (sh - wh * fh) / 2))
        echo "o" >/tmp/mp3xterm.tmp
        xterm +sb -b 8 -geometry ${ww}x$wh+$xp+$yp -fn ${fw}x$fh \
            -title MP3 -fg white -bg black \
            -e "echo -n \"$info\"; read ret; echo \"\$ret\">/tmp/mp3xterm.tmp"
        ret=`cat /tmp/mp3xterm.tmp`
    else
        clear
        echo -ne "$info"
        read ret
    fi
    if [ -z "$ret" ]; then
        ret=o
    fi
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
ret=n
if [ -f "$log" ]; then
    dialog
fi
while [ "$ret" = n ]; do
    mp3rand.sh >/dev/null
    dialog
done

if [ "$ret" = o ]; then
    nyxmms2 play
else
    album=`head -n $ret /tmp/mp3rand-i.tmp | tail -n 1 | cut -c12-`
    mp3rand.sh "$album/00.m3u"
fi
