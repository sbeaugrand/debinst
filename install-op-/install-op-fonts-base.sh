# ---------------------------------------------------------------------------- #
## \file install-op-fonts-base.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
texdir=$home/texmf
repo=$idir/../repo

download http://mirrors.ctan.org/fonts/$name.zip || return 1

if notDir $bdir/$name; then
    pushd $bdir || return 1
    unzip -qq $repo/$name.zip
    popd
fi

copyFiles()
{
    ext=$1
    dir=$texdir/$2
    mkdir -p $dir
    find . -name "*.$ext" -exec cp -uv {} $dir/ \; >>$log
}

copyMap()
{
    file=$1
    dir=$texdir/$2
    if notFile $dir/$file; then
        mkdir -p $dir
        cp $name.map $dir/$file
    fi
}

tracepfb()
{
    font=$1
    pushd $dir || return 1
    tfm=$texdir/fonts/tfm/public/$name/$font.tfm
    enc=$idir/install-ob-/install-13-fonts/T1-WGL4.enc
    mftrace --formats=pfb -V --tfmfile=$tfm -e $enc $font.mf >>$log 2>&1
    mv $font.pfb $texdir/fonts/type1/public/frcursive/
    popd
}

if notFile $texdir/tex/latex/$name/$name.sty; then
    pushd $bdir/$name || return 1
    copyFiles mf fonts/source/public/$name
    copyFiles alf fonts/source/public/$name
    copyFiles def fonts/source/public/$name
    copyFiles num fonts/source/public/$name
    copyFiles pfb fonts/type1/public/$name
    copyFiles tfm fonts/tfm/public/$name
    copyFiles sty tex/latex/$name
    copyFiles fd tex/latex/$name
    if [ -f $name.map ]; then
        copyMap pdftex.map fonts/map/pdftex/updmap/$name
        copyMap psfonts.map fonts/map/dvips/updmap/$name
        file=$texdir/web2c/updmap.cfg
        if notGrep "$name" $file; then
            mkdir -p $texdir/web2c
            echo "MixedMap $name.map" >>$file
        fi
    fi
    texhash $texdir >>$log
    popd
fi
