# ---------------------------------------------------------------------------- #
## \file install-op-imscripts.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../bin
[ -d $repo ] || sudo -u $user mkdir $repo

url="http://www.fmwconcepts.com/imagemagick/downloadcounter.php"

downloadScript()
{
    script=$1
    file=$repo/$script
    if notFile $file; then
        curl -s "$url?scriptname=$script&dirname=$script" -o $file || return 1
        chown $user.$user $file
        chmod 755 $file
    fi
}

downloadScript autowhite
downloadScript autotone
