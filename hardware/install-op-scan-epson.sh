# ---------------------------------------------------------------------------- #
## \file install-op-scan-epson.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=6.7.65.0
repo=$idir/../repo
url="https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=JA&CN2=US&CTI=171&PRN=Linux%20deb%2064bit%20package&OSC=LX&DL"

dir=epsonscan2-bundle-$version.x86_64.deb
file=epsonscan2_$version-1_amd64.deb
download "$url" $dir.tar.gz || return 1
untar $dir.tar.gz $dir/core/$file || return 1

if notWhich epsonscan2; then
    sudoRoot dpkg -i $bdir/$dir/core/$file
fi
