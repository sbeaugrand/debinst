# ---------------------------------------------------------------------------- #
## \file install-21-w3m.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.w3m/config

if notFile $file; then
    mkdir -p $home/.w3m
    echo "anchor_color cyan" >$file
    chown -R $user.$user $home/.w3m
elif notGrep "anchor_color cyan" $file; then
    sed -i 's/anchor_color .*/anchor_color cyan/' $file
fi
