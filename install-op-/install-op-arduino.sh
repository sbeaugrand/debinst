# ---------------------------------------------------------------------------- #
## \file install-op-arduino.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.0.6
file=arduino-$version-linux64.tgz
repo=$idir/../repo

download https://downloads.arduino.cc/$file || return 1
untar $file arduino-$version/arduino || return 1

gitClone https://github.com/SpenceKonde/ATTinyCore.git || return 1

gitClone https://github.com/PaulStoffregen/TimerOne.git || return 1

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1017826
file=/usr/share/arduino/hardware/arduino/avr/platform.txt
if notGrep ctags $file; then
    cp $file $tmpf
    echo 'tools.ctags.pattern=/usr/bin/arduino-ctags  -u --language-force=c++ -f - --c++-kinds=svpf --fields=KSTtzns --line-directives "{source_file}"' >>$tmpf
    sudoRoot cp $tmpf $file
fi

dir=$bdir/arduino-$version/examples/ArduinoISP
if notFile $dir/ArduinoISP.ino.hex; then
    pushd $dir || return 1
    arduino-builder -hardware /usr/share/arduino/hardware -tools /usr/bin -fqbn arduino:avr:mega:cpu=atmega2560 -verbose ArduinoISP.ino
    cp /tmp/arduino-sketch-*/ArduinoISP.ino.hex . || return 1
    popd
fi

logTodo "avrdude -c wiring -p ATmega2560 -D -P /dev/ttyACM0 -U flash:w:ArduinoISP.ino.hex"
