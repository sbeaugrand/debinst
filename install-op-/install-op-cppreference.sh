# ---------------------------------------------------------------------------- #
## \file install-op-cppreference.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=20240610
repo=$idir/../repo
file=html-book-$version.tar.xz
url=https://github.com/PeterFeicht/cppreference-doc/releases/download/v$version

download $url/$file || return 1
untar $file reference/en || return 1
