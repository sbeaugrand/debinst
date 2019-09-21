# ---------------------------------------------------------------------------- #
## \file install-10-wiringPI.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$repo/wiringPi

if notDir $dir; then
    pushd $repo || return 1
    git clone -q git://git.drogon.net/wiringPi >>$log
    popd

    pushd $dir/wiringPi || return 1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd

    pushd $dir/devLib || return 1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi
