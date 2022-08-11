#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-13-fonts.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd install-ob-/install-*-fonts || return 1
make install >>$log 2>&1
make >>$log 2>&1
popd

if notFile install-ob-/install-*-fonts/runes/runes.pfb; then
    pushd install-ob-/install-*-fonts/runes || return 1
    make pfb >>$log 2>&1
    popd
fi

makeTTF()
{
    name=$1
    if notFile install-ob-/install-*-fonts/$name/$name.ttf; then
        pushd install-ob-/install-*-fonts/$name || return 1
        make ttf >>$log 2>&1
        popd
    fi
    if notFile $dir/$name.ttf; then
        cp install-ob-/install-*-fonts/$name/$name.ttf $dir/
    fi
}

dir=$home/.local/share/fonts/truetype
if notDir $dir; then
    mkdir -p $dir
fi
makeTTF runes
makeTTF noeuds

dir=/usr/share/inkscape/fonts
if notDir $dir; then
    sudoRoot mkdir -p $dir
fi
