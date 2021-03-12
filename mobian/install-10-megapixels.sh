# ---------------------------------------------------------------------------- #
## \file install-10-megapixels.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/usr/share/megapixels/postprocess.sh

PICTURE_DIR=$(cat /home/mobian/.config/user-dirs.dirs | grep PICTURES | cut -d/ -f2 | cut -d\" -f1)

if notGrep '^TARGET_NAME="/home/mobian' $file; then
    sed -i "s@^TARGET_NAME=.*@TARGET_NAME=\"/home/mobian/$PICTURE_DIR/\${2##*/}\"@" $file
fi
