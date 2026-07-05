# ---------------------------------------------------------------------------- #
## \file install-op-ansible-manual.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/ansible-manual
if notDir $dir; then
    mkdir $dir
    pushd $dir
    $idir/bin/aspire.sh -nd https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/index.html
    popd
    logTodo "chromium file://$dir/index.html#modules"
fi
