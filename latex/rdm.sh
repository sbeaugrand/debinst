# ---------------------------------------------------------------------------- #
## \file rdm.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/Philippe-Lawrence/pyBar.git || return 1
sed -i '/set_user_dir/D' $bdir/pyBar/pyBar.py

file=EPB_SI.zip
url=http://s2i.pinault-bigeard.com/telechargements/category/15-latex
download $url?download=236:epb-si-zip $file || return 1
untar $file || return 1

pushd latex/rdm || return 1
make HOME=$home >>$log 2>&1
chown -R $user.$user .
popd
