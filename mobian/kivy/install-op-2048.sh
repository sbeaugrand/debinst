# ---------------------------------------------------------------------------- #
## \file install-op-2048.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note test with "fbcli -E alarm-clock-elapsed"
# ---------------------------------------------------------------------------- #
# For android :
#   sudo apt install openjdk-11-jdk libltdl-dev zip adb
#   pip3 install -U buildozer
#   pip3 install -U cython
#   buildozer android debug  # 2.1G needed + 3.6G in ~/.buildozer
#   adb install -r bin/*.apk
#   Debug :
#     adb shell logcat | grep python
# ---------------------------------------------------------------------------- #
gitClone https://github.com/sbeaugrand/2048 || return 1

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
