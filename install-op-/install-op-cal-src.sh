# ---------------------------------------------------------------------------- #
## \file install-op-cal-src.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || mkdir $repo
url=http://dante.ctan.org/tex-archive

file=calendar.zip
download $url/macros/plain/contrib/$file || return 1

file=moonphase.mf
download $url/fonts/moonphase/$file || return 1
