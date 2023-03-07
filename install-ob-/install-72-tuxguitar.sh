# ---------------------------------------------------------------------------- #
## \file install-72-tuxguitar.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=`ls $home/.tuxguitar-*/config.properties 2>/dev/null`
if [ -z "$file" ]; then
    tuxguitar >>$log 2>&1 &
    sleep 10
    pid=`pgrep -f tuxguitar`
    if [ -n "$pid" ]; then
        kill -15 $pid
    fi
    file=`ls $home/.tuxguitar-*/config.properties`
    if [ -z "$file" ]; then
        return 1
    fi
fi

if notGrep "tuxguitar-alsa_128-0" $file; then
    echo "midi.sequencer=tuxguitar.sequencer" >>$file
    echo "midi.port=tuxguitar-alsa_128-0" >>$file
fi
