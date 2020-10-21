# ---------------------------------------------------------------------------- #
## \file cal.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo
url=ftp://dante.ctan.org/tex-archive

file=calendar.zip
download $url/macros/plain/contrib/$file || return 1
untar $file || return 1

file=moonphase.mf
download $url/fonts/moonphase/$file || return 1

# build
dir=latex/cal/build
if notDir $dir; then
    mkdir $dir
fi
dir=latex/cal/build/calendar
if notDir $dir; then
    ln -s $bdir/calendar $dir
fi
file=latex/cal/build/moonphase.mf
if notLink $file; then
    ln -s $repo/moonphase.mf $file
fi

pushd latex/cal || return 1
make >>$log 2>&1 cal
make >>$log 2>&1 cadran
popd

chown -R $user.$user latex/cal
