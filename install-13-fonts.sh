#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file install-13-fonts.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd install-*-fonts || return 1
make install >>$log 2>&1
make >>$log 2>&1
popd

if notFile install-*-fonts/runes/runes.pfb; then
    pushd install-*-fonts/runes || return 1
    make pfb >>$log 2>&1
    popd
fi

makeTTF()
{
    name=$1
    if notFile install-*-fonts/$name/$name.ttf; then
        pushd install-*-fonts/$name || return 1
        make ttf >>$log 2>&1
        popd
    fi
    if notFile /usr/share/fonts/truetype/$name.ttf; then
        cp install-*-fonts/$name/$name.ttf /usr/share/fonts/truetype/
    fi
}

makeTTF runes
makeTTF noeuds
