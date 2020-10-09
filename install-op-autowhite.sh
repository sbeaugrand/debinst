# ---------------------------------------------------------------------------- #
## \file install-op-autowhite.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../bin
[ -d $repo ] || sudo -u $user mkdir $repo

file=$repo/autowhite.sh
if notFile $file; then
    curl -s 'http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=autowhite&dirname=autowhite' -o $file || return 1
    chown $user.$user $file
    chmod 755 $file
fi
