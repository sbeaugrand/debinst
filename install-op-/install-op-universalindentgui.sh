# ---------------------------------------------------------------------------- #
## \file install-op-universalindentgui.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitClone https://github.com/maximevince/universal-indent-gui.git

if [ ! -f /usr/lib/x86_64-linux-gnu/pkgconfig/Qt5Script.pc ]; then
    sudoRoot apt-get install -y qtscript5-dev
fi
if [ ! -f /usr/include/x86_64-linux-gnu/qt5/Qsci/qsciscintilla.h ]; then
    sudoRoot apt-get install -y libqscintilla2-qt5-dev
fi

if notWhich universalindentgui; then
    dir=$bdir/universal-indent-gui/build
    mkdir -p $dir
    pushd $dir || return 1
    qmake ../UniversalIndentGUI.pro
    make
    cp release/universalindentgui $home/.local/bin/
    popd
fi

dir=/usr/share/universalindentgui
if notDir $dir; then
    sudoRoot mkdir $dir
    sudoRoot cp -ru $bdir/universal-indent-gui/indenters $dir/
fi

file=$dir/indenters/uigui_uncrustify.ini
if grep -q "Align Number Left" $file; then
    version=`apt show uncrustify 2>/dev/null | grep "Version:" | cut -d ' ' -f 2 | cut -d '+' -f 1`
    download https://github.com/uncrustify/uncrustify/raw/uncrustify-$version/etc/uigui_uncrustify.ini || return 1
    sudoRoot cp $repo/uigui_uncrustify.ini $file
fi
