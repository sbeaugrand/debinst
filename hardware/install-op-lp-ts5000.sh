# ---------------------------------------------------------------------------- #
## \file install-op-lp-ts5000.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

# https://github.com/Ordissimo/scangearmp2/releases
# https://github.com/Ordissimo/scangearmp2/releases/download/4.12/scangearmp2_4.12-1bullseye+1_amd64.deb
# sudo dpkg -i
# sudo apt-get install sane-utils
# scanimage -L
# device 'canon_pixma:F4-A9-97-8C-EF-7A' is a CANON TS5000 series flatbed scanner
# cp scangearmp2.desktop ~/.local/share/applications/

gitClone https://github.com/Ordissimo/scangearmp2.git || return 1

if notWhich scanimage; then
    apt-get install sane-utils
fi
if notFile /usr/include/jpeglib.h; then
    apt-get install libjpeg-dev
fi
if notFile /usr/include/sane/sane.h; then
    apt-get install libsane-dev
fi

if notWhich scangearmp2; then
    pushd $bdir/scangearmp2 || return 1
    mkdir -p build
    pushd $bdir/scangearmp2/build || return 1
    PATH=$PATH:/usr/share/intltool-debian cmake .. >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

file=$home/.local/share/applications/scangearmp2.desktop
if notFile $file; then
    cp $idir/hardware/scangearmp2.desktop $file
fi

cat <<EOF

https://www.canon.fr/support/business-product-support/
tar xzf cnijfilter2-5.40-1-deb.tar.gz
cd cnijfilter2-5.40-1-deb
sudo apt-get install libcupsimage2
./install.sh
lpoptions -d TS5000LAN

EOF
