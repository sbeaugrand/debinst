# ---------------------------------------------------------------------------- #
## \file install-op-avidemux.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=2.8.0
repo=$idir/../repo

if isOnline; then
    url=http://fixounet.free.fr/avidemux/download.html
    version=`curl -s $url |\
     grep sourceforge | head -n 1 | sed 's#.*/\([0-9.]\+\)/.*#\1#'`
fi
echo " info: version=$version"

# https://sourceforge.net/projects/avidemux/files/avidemux/
url=https://freefr.dl.sourceforge.net/project/avidemux/avidemux
app=avidemux_$version.appImage
download $url/$version/$app || return 1
download $url/$version/md5sum.txt $app.md5 || return 1
pushd $repo || return 1
chmod 755 $app
grep $app $app.md5 >$app.tmp && mv $app.tmp $app.md5
md5sum --quiet -c $app.md5 || return 1
popd

file=$home/.local/bin/$app
if notFile $file; then
    cp $repo/$app $file
fi
