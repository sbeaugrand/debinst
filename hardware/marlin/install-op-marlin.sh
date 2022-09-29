# ---------------------------------------------------------------------------- #
## \file install-op-marlin.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# Arduino
#version=1.8.13
#file=arduino-$version-linux64.tar.xz
#download https://downloads.arduino.cc/$file || return 1
#untar $file arduino-$version/arduino || return 1
#arduino=$bdir/arduino-$version
#file=$arduino/hardware/arduino/avr/platform.local.txt
file=/usr/share/arduino/hardware/arduino/avr/platform.local.txt
if notFile $file; then
    echo 'tools.ctags.pattern=ctags -u "{source_file}"' >$file
fi

# Marlin
source hardware/marlin/install-op-marlin-src.sh || return 1

dir=$bdir/Marlin/Marlin
if notGrep '^#define EEPROM_SETTINGS' $dir/Configuration.h; then
    pushd $dir || return 1
    git apply $idir/install-op-marlin.patch
    popd
fi

if notFile $dir/Marlin.ino.hex; then
    pushd $dir || return 1
    #$arduino/arduino-builder -hardware $arduino/hardware -tools $arduino/hardware/tools -fqbn arduino:avr:mega:cpu=atmega2560 -verbose Marlin.ino
    arduino-builder -hardware /usr/share/arduino/hardware -tools /usr/bin -fqbn arduino:avr:mega:cpu=atmega2560 -verbose Marlin.ino
    cp /tmp/arduino-sketch-*/Marlin.ino.hex . || return 1
    popd
fi

logTodo "avrdude -c wiring -p ATmega2560 -D -P /dev/ttyACM0 -U flash:w:Marlin.ino.hex"
