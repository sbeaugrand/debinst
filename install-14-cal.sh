# ---------------------------------------------------------------------------- #
## \file install-14-cal.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../calendar
url=ftp://dante.ctan.org/tex-archive

file=calendar.zip
download $url/macros/plain/contrib/$file || return 1
untar $file || return 1

file=moonphase.mf
download $url/fonts/moonphase/$file || return 1

# build
dir=install-14-cal/build
if notDir $dir; then
    mkdir $dir
fi
dir=install-14-cal/build/calendar
if notLink $dir; then
    ln -s $bdir/calendar $dir
fi
file=install-14-cal/build/moonphase.mf
if notLink $file; then
    ln -s $repo/moonphase.mf $file
fi

pushd install-14-cal || return 1
touch calendar/calend0.tex
make cal >>$log 2>&1
make cadran >>$log 2>&1
popd

chown -R $user.$user install-14-cal
