# ---------------------------------------------------------------------------- #
## \file install-op-dafont.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dafont()
{
    name="$1"
    font="$2"
    file="$name.zip"

    download http://dl.dafont.com/dl/?f=$name $file || return 1

    if notFile "/usr/share/fonts/truetype/$font"; then
        pushd /usr/share/fonts/truetype || return 1
        unzip $repo/$file "$font" >>$log
        popd
    fi
}

dafont augusta "Augusta.ttf"
dafont augusta "Augusta-Shadow.ttf"
dafont sleep_on_the_moon "Sleep on the moon.ttf"
dafont glam_queen "Glam_Queen.ttf"
