# ---------------------------------------------------------------------------- #
## \file install-op-2048.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# For android :
#   sudo apt install openjdk-21-jdk libltdl-dev zip adb
#   pip install -U buildozer
#   pip install -U cython
#   buildozer android debug  # __GNUC_PREREQ is not defined
#   sudo mv /usr/include/x86_64-linux-gnu /usr/include/x86_64-linux-gnu.bak  #FIXME: https://stackoverflow.com/a/79583260
#   buildozer android debug  # 4.0G needed in ./.buildozer + 3.4G in ~/.buildozer
#   sudo mv /usr/include/x86_64-linux-gnu.bak /usr/include/x86_64-linux-gnu
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
Exec=python3 $home/data/install-build/2048/main.py
Type=Application
Terminal=false
Categories=Game;
Path=$home/data/install-build/2048
StartupNotify=false
EOF
fi
