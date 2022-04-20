# ---------------------------------------------------------------------------- #
## \file install-op-2048.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note test with "fbcli -E alarm-clock-elapsed"
# ---------------------------------------------------------------------------- #
gitClone https://github.com/tito/2048 || return 1

file=$home/.local/share/applications/kivy2048.desktop
if notFile $file; then
    cat >$file <<EOF
[Desktop Entry]
Name=2048
Comment=2048 Game with Kivy
Icon=$home/data/install-build/2048/data/icon.png
Exec=env KIVY_WINDOW=x11 python3 $home/data/install-build/2048/main.py
Type=Application
Terminal=false
Categories=Game;
Path=$home/data/install-build/2048
EOF
fi

file=$bdir/2048/main.py
if notGrep '^platform = None' $file; then
    sed -i 's/^platform =.*/platform = None/' $file
fi

# For android :
#   sudo apt install openjdk-11-jdk libltdl-dev zip adb
#   pip3 install buildozer
#   pip3 install cython
#   buildozer android debug  # 1,5G needed
#   adb install bin/*.apk
file=$bdir/2048/buildozer.spec
if notGrep 'android.archs' $file; then
    pushd $bdir/2048 || return 1
    git apply $idir/mobian/kivy/install-op-2048.patch
    popd
fi
