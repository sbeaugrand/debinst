# ---------------------------------------------------------------------------- #
## \file install-op-camotics.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.2.0
repo=$idir/../repo

if isOnline; then
    url=https://camotics.org/download.html
    version=`curl -s $url | grep Version | sed 's#.* \([0-9.]\+\).*#\1#'`
fi
logInfo "camotics version=$version"

url=https://camotics.org/builds/release/debian-stable-64bit
app=camotics_${version}_amd64.deb
download $url/$app || return 1

if notWhich camotics; then
    sudoRoot apt-get -q -y install $repo/$app
fi

version=3.14.5
file=/usr/lib/x86_64-linux-gnu/libv8.so.$version
if notLink $file; then
    sudoRoot ln -s /usr/lib/x86_64-linux-gnu/libv8.so $file
fi

file=$home/.local/bin/$app
if notFile $file; then
    cp $repo/$app $file
fi
