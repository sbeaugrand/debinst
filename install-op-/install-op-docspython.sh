# ---------------------------------------------------------------------------- #
## \file install-op-docspython.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=3.14
repo=$idir/../repo
file=python-$version-docs-html.tar.bz2

download https://docs.python.org/fr/3/archives/$file || return 1
