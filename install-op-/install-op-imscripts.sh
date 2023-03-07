# ---------------------------------------------------------------------------- #
## \file install-op-imscripts.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
url="http://www.fmwconcepts.com/imagemagick/downloadcounter.php"

downloadScript()
{
    script=$1
    file=`readlink -f $repo/$script`
    if notFile $file; then
        curl -s "$url?scriptname=$script&dirname=$script" -o $file || return 1
        chmod 755 $file
    fi
    if notFile $home/.local/bin/$script; then
        cp $file $home/.local/bin/$script
    fi
}

downloadScript autowhite
downloadScript autotone
